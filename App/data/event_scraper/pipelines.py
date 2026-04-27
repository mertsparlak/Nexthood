# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

import logging
import os
import re
from datetime import datetime, timezone
from itemadapter import ItemAdapter
from scrapy.exceptions import DropItem

logger = logging.getLogger(__name__)


class CleaningPipeline:
    """
    Pipeline 1: Data cleaning and normalization.
    - Strips HTML tags and extra whitespace
    - Validates required fields
    - Normalizes date formats
    - Ensures consistent data types
    """

    def process_item(self, item, spider):
        adapter = ItemAdapter(item)

        # ── Validate required fields ──
        title = adapter.get("title")
        if not title or not title.strip():
            raise DropItem(f"Missing title: {item}")

        # ── Clean text fields ──
        for field in ["title", "description", "location_name"]:
            value = adapter.get(field)
            if value:
                # Remove HTML tags
                value = re.sub(r"<[^>]+>", "", str(value))
                # Normalize whitespace
                value = re.sub(r"\s+", " ", value).strip()
                adapter[field] = value

        # ── Truncate title if too long ──
        if len(adapter["title"]) > 255:
            adapter["title"] = adapter["title"][:252] + "..."

        # ── Ensure boolean type for is_free ──
        is_free = adapter.get("is_free")
        if is_free is None:
            adapter["is_free"] = True
        elif isinstance(is_free, str):
            adapter["is_free"] = is_free.lower() in ("true", "1", "evet", "ücretsiz")

        # ── Validate coordinates ──
        lat = adapter.get("latitude")
        lng = adapter.get("longitude")
        if lat is not None:
            try:
                lat = float(lat)
                if not (-90 <= lat <= 90):
                    lat = None
            except (ValueError, TypeError):
                lat = None
            adapter["latitude"] = lat

        if lng is not None:
            try:
                lng = float(lng)
                if not (-180 <= lng <= 180):
                    lng = None
            except (ValueError, TypeError):
                lng = None
            adapter["longitude"] = lng

        # ── Validate URLs ──
        for url_field in ["image_url", "event_url", "source_url"]:
            url = adapter.get(url_field)
            if url and not url.startswith("http"):
                adapter[url_field] = None

        return item


class DuplicateFilterPipeline:
    """
    Pipeline 2: In-memory duplicate detection.
    Filters events based on (event_url) or (title + start_date) uniqueness.
    """

    def __init__(self):
        self.seen_urls = set()
        self.seen_titles = set()

    def process_item(self, item, spider):
        adapter = ItemAdapter(item)

        # Primary dedup: by event_url (most reliable)
        event_url = adapter.get("event_url")
        if event_url and event_url in self.seen_urls:
            raise DropItem(f"Duplicate event URL: {event_url}")
        if event_url:
            self.seen_urls.add(event_url)
            return item  # URL is unique, no need for secondary check

        # Secondary dedup: by title + date (only when no URL)
        title = adapter.get("title", "")
        start_date = adapter.get("start_date") or ""
        title_key = f"{title.lower().strip()}|{start_date}"
        if title_key in self.seen_titles:
            raise DropItem(f"Duplicate event: {title}")
        self.seen_titles.add(title_key)

        return item


class JsonExportPipeline:
    """
    Pipeline 3: Exports events to a JSON file for debugging and review.
    The JSON file can be imported into the database via the FastAPI admin API.
    """

    def __init__(self):
        self.items = []

    def process_item(self, item, spider):
        adapter = ItemAdapter(item)
        self.items.append(dict(adapter))
        return item

    def close_spider(self, spider):
        if self.items:
            import json
            output_dir = os.path.join(os.path.dirname(__file__), "..", "output")
            os.makedirs(output_dir, exist_ok=True)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"events_{spider.name}_{timestamp}.json"
            filepath = os.path.join(output_dir, filename)

            with open(filepath, "w", encoding="utf-8") as f:
                json.dump(self.items, f, ensure_ascii=False, indent=2, default=str)

            logger.info(
                f"[{spider.name}] Exported {len(self.items)} events to {filepath}"
            )


class PostgresPipeline:
    """
    Pipeline 4: Writes events to PostgreSQL database.
    Uses SQLAlchemy with sync engine for Scrapy compatibility.
    Performs upsert based on (source_id, event_url) unique constraint.
    """

    def __init__(self):
        self.engine = None
        self.Session = None

    def open_spider(self, spider):
        """Initialize database connection when spider starts."""
        from sqlalchemy import create_engine
        from sqlalchemy.orm import sessionmaker

        db_url = os.getenv(
            "DATABASE_URL",
            "postgresql://postgres:123456@127.0.0.1:5433/mahalle_connect",
        )
        # Convert async URL to sync if needed
        db_url = db_url.replace("postgresql+asyncpg://", "postgresql://")

        try:
            self.engine = create_engine(db_url, echo=False)
            self.Session = sessionmaker(bind=self.engine)
            logger.info(f"[{spider.name}] PostgreSQL connection established")
        except Exception as e:
            logger.error(f"[{spider.name}] Failed to connect to PostgreSQL: {e}")
            self.engine = None

    def close_spider(self, spider):
        """Close database connection when spider finishes."""
        if self.engine:
            self.engine.dispose()
            logger.info(f"[{spider.name}] PostgreSQL connection closed")

    def process_item(self, item, spider):
        """Upsert event into the database."""
        if not self.Session:
            return item

        adapter = ItemAdapter(item)
        session = self.Session()

        try:
            # Import models here to avoid circular imports
            import sys
            sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "backend"))

            from sqlalchemy import select, text
            from geoalchemy2.shape import from_shape
            from shapely.geometry import Point

            # ── Find or create ScrapedSource ──
            source_url = adapter.get("source_url", "")
            source_name = adapter.get("source_name", spider.name)

            source_result = session.execute(
                text("SELECT id FROM scraped_sources WHERE url = :url"),
                {"url": source_url},
            ).fetchone()

            if source_result:
                source_id = source_result[0]
            else:
                # Create new source
                result = session.execute(
                    text("""
                        INSERT INTO scraped_sources (id, source_name, url, is_active, scrape_interval_hours, last_scrape_status)
                        VALUES (gen_random_uuid(), :name, :url, true, 24, 'pending')
                        RETURNING id
                    """),
                    {"name": source_name, "url": source_url},
                )
                source_id = result.fetchone()[0]
                session.commit()

            # ── Build geometry point ──
            lat = adapter.get("latitude")
            lng = adapter.get("longitude")
            location_wkt = None
            if lat and lng:
                location_wkt = f"SRID=4326;POINT({lng} {lat})"

            # ── Parse dates ──
            start_date = adapter.get("start_date")
            if start_date:
                try:
                    start_date = datetime.fromisoformat(start_date)
                except (ValueError, TypeError):
                    start_date = datetime.now(timezone.utc)
            else:
                start_date = datetime.now(timezone.utc)

            end_date = adapter.get("end_date")
            if end_date:
                try:
                    end_date = datetime.fromisoformat(end_date)
                except (ValueError, TypeError):
                    end_date = None

            # ── Upsert event ──
            event_url = adapter.get("event_url", "")

            existing = session.execute(
                text("SELECT id FROM events WHERE source_id = :sid AND event_url = :url"),
                {"sid": str(source_id), "url": event_url},
            ).fetchone()

            if existing:
                # Update existing event
                session.execute(
                    text("""
                        UPDATE events SET
                            title = :title,
                            description = :description,
                            start_date = :start_date,
                            end_date = :end_date,
                            location_name = :location_name,
                            location = :location,
                            category = :category,
                            image_url = :image_url,
                            is_free = :is_free,
                            updated_at = NOW()
                        WHERE id = :id
                    """),
                    {
                        "id": str(existing[0]),
                        "title": adapter.get("title"),
                        "description": adapter.get("description"),
                        "start_date": start_date,
                        "end_date": end_date,
                        "location_name": adapter.get("location_name"),
                        "location": location_wkt,
                        "category": adapter.get("category", "etkinlik"),
                        "image_url": adapter.get("image_url"),
                        "is_free": adapter.get("is_free", True),
                    },
                )
                logger.debug(f"Updated event: {adapter.get('title')}")
            else:
                # Insert new event
                session.execute(
                    text("""
                        INSERT INTO events (
                            id, source_id, title, description,
                            start_date, end_date, location_name, location,
                            category, image_url, event_url, is_free,
                            status, is_deleted, created_at, updated_at
                        ) VALUES (
                            gen_random_uuid(), :source_id, :title, :description,
                            :start_date, :end_date, :location_name, :location,
                            :category, :image_url, :event_url, :is_free,
                            'active', false, NOW(), NOW()
                        )
                    """),
                    {
                        "source_id": str(source_id),
                        "title": adapter.get("title"),
                        "description": adapter.get("description"),
                        "start_date": start_date,
                        "end_date": end_date,
                        "location_name": adapter.get("location_name"),
                        "location": location_wkt,
                        "category": adapter.get("category", "etkinlik"),
                        "image_url": adapter.get("image_url"),
                        "event_url": event_url,
                        "is_free": adapter.get("is_free", True),
                    },
                )
                logger.info(f"Inserted new event: {adapter.get('title')}")

            # ── Update ScrapedSource status ──
            session.execute(
                text("""
                    UPDATE scraped_sources SET
                        last_scraped_at = NOW(),
                        last_scrape_status = 'success',
                        last_scrape_error = NULL
                    WHERE id = :id
                """),
                {"id": str(source_id)},
            )

            session.commit()

        except Exception as e:
            session.rollback()
            logger.error(f"[{spider.name}] DB error for '{adapter.get('title')}': {e}")

            # Update source with error status
            try:
                session.execute(
                    text("""
                        UPDATE scraped_sources SET
                            last_scrape_status = 'failed',
                            last_scrape_error = :error
                        WHERE url = :url
                    """),
                    {"error": str(e)[:500], "url": adapter.get("source_url", "")},
                )
                session.commit()
            except Exception:
                session.rollback()

        finally:
            session.close()

        return item

