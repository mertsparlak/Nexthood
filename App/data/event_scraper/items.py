# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class EventScraperItem(scrapy.Item):
    """
    Represents a single event scraped from a municipality website.
    Fields are designed to map directly to the backend Event model.
    """
    # Core Event Fields
    title = scrapy.Field()
    description = scrapy.Field()
    start_date = scrapy.Field()       # ISO 8601 datetime string
    end_date = scrapy.Field()         # ISO 8601 datetime string (optional)

    # Location
    location_name = scrapy.Field()    # Human-readable location (e.g. "Kadıköy Kültür Merkezi")
    latitude = scrapy.Field()         # Float, for PostGIS POINT
    longitude = scrapy.Field()        # Float, for PostGIS POINT

    # Classification
    category = scrapy.Field()         # e.g. konser, tiyatro, sergi, workshop, spor, festival, seminer

    # Media & Links
    image_url = scrapy.Field()        # Event poster/thumbnail URL
    event_url = scrapy.Field()        # Original event detail page URL

    # Pricing
    is_free = scrapy.Field()          # Boolean, default True for municipality events

    # Source Tracking
    source_name = scrapy.Field()      # e.g. "Kadıköy Belediyesi"
    source_url = scrapy.Field()       # Base URL of the source website
    district = scrapy.Field()         # İlçe adı (e.g. "Kadıköy")
