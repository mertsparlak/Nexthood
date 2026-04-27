"""
Base spider with shared utilities for all municipality event spiders.
Provides common date parsing, category detection, and coordinate mapping
for all 39 Istanbul districts + İBB.
"""
import scrapy
import re
import logging
from datetime import datetime
from urllib.parse import urlparse
from event_scraper.items import EventScraperItem

logger = logging.getLogger(__name__)


# ─── District Center Coordinates (approximate WGS84) ───
DISTRICT_COORDINATES = {
    "İBB":           (41.0082, 28.9784),
    "Adalar":        (40.8761, 29.0900),
    "Arnavutköy":    (41.1850, 28.7394),
    "Ataşehir":      (40.9833, 29.1167),
    "Avcılar":       (40.9796, 28.7217),
    "Bağcılar":      (41.0386, 28.8572),
    "Bahçelievler":  (41.0000, 28.8617),
    "Bakırköy":      (40.9800, 28.8720),
    "Başakşehir":    (41.0940, 28.8090),
    "Bayrampaşa":    (41.0467, 28.9117),
    "Beşiktaş":      (41.0422, 29.0067),
    "Beykoz":        (41.1267, 29.0917),
    "Beylikdüzü":    (41.0050, 28.6400),
    "Beyoğlu":       (41.0370, 28.9770),
    "Büyükçekmece":  (41.0200, 28.5850),
    "Çatalca":       (41.1433, 28.4617),
    "Çekmeköy":      (41.0417, 29.1833),
    "Esenler":       (41.0436, 28.8764),
    "Esenyurt":      (41.0283, 28.6750),
    "Eyüpsultan":    (41.0483, 28.9350),
    "Fatih":         (41.0186, 28.9496),
    "Gaziosmanpaşa": (41.0650, 28.9117),
    "Güngören":      (41.0200, 28.8817),
    "Kadıköy":       (40.9927, 29.0230),
    "Kağıthane":     (41.0800, 28.9717),
    "Kartal":        (40.8899, 29.1893),
    "Küçükçekmece":  (41.0000, 28.7800),
    "Maltepe":       (40.9350, 29.1300),
    "Pendik":        (40.8767, 29.2583),
    "Sancaktepe":    (41.0017, 29.2300),
    "Sarıyer":       (41.1667, 29.0500),
    "Silivri":       (41.0733, 28.2467),
    "Sultanbeyli":   (40.9617, 29.2633),
    "Sultangazi":    (41.1050, 28.8667),
    "Şile":          (41.1767, 29.6133),
    "Şişli":         (41.0600, 28.9867),
    "Tuzla":         (40.8167, 29.2983),
    "Ümraniye":      (41.0167, 29.1167),
    "Üsküdar":       (41.0236, 29.0154),
    "Zeytinburnu":   (41.0033, 28.9067),
}


# ─── Turkish Month Mapping ───
TR_MONTHS = {
    "ocak": 1, "şubat": 2, "mart": 3, "nisan": 4,
    "mayıs": 5, "haziran": 6, "temmuz": 7, "ağustos": 8,
    "eylül": 9, "ekim": 10, "kasım": 11, "aralık": 12,
}

# ─── Abbreviated months ───
TR_MONTHS_SHORT = {
    "oca": 1, "şub": 2, "mar": 3, "nis": 4,
    "may": 5, "haz": 6, "tem": 7, "ağu": 8,
    "eyl": 9, "eki": 10, "kas": 11, "ara": 12,
}


# ─── Category Keywords ───
CATEGORY_KEYWORDS = {
    "konser": [
        "konser", "müzik", "caz", "rock", "pop", "orkestra",
        "filarmoni", "resital", "senfoni", "koro", "piyano",
        "gitar", "kemançe", "türkü", "fasıl",
    ],
    "tiyatro": [
        "tiyatro", "oyun", "sahne", "drama", "komedi",
        "gösteri", "stand-up", "standup", "kukla", "pandomim",
    ],
    "sergi": [
        "sergi", "galeri", "resim", "heykel", "sanat",
        "fotoğraf", "enstalasyon", "koleksiyon", "bienal",
    ],
    "workshop": [
        "atölye", "workshop", "çalıştay", "kurs", "eğitim",
        "seminer", "söyleşi", "sunum", "konferans", "panel",
    ],
    "spor": [
        "spor", "koşu", "yüzme", "fitness", "yoga",
        "pilates", "basketbol", "futbol", "zumba", "voleybol",
        "tenis", "boks", "jimnastik", "bisiklet",
    ],
    "festival": [
        "festival", "şenlik", "karnaval", "bayram", "kutlama",
    ],
    "sinema": [
        "sinema", "film", "belgesel", "kısa film", "gösterim",
        "vizyon", "açık hava sineması",
    ],
    "edebiyat": [
        "şiir", "edebiyat", "okuma", "yazar", "kitap",
        "imza", "söyleşi", "hikaye", "roman",
    ],
    "çocuk": [
        "çocuk", "kids", "minik", "bebek", "masal",
        "oyun parkı", "animasyon",
    ],
    "gezi": [
        "gezi", "tur", "yürüyüş", "keşif", "tarih",
        "müze", "miras", "kültürel gezi",
    ],
    "dans": [
        "dans", "bale", "halk oyunu", "folklor", "latin",
        "tango", "vals", "salsa",
    ],
}


def parse_turkish_date(date_text: str) -> str | None:
    """
    Parse Turkish date strings into ISO 8601 format.
    Handles formats like:
      - "27 Nisan 2026"
      - "27.04.2026"
      - "27 Nisan 2026, 14:00"
      - "27/04/2026"
      - "2026-04-27"
      - "27 Nis 2026"
      - "Nisan 27, 2026"
      - "27 Nisan Pazartesi" (Current year implied)
    Returns ISO 8601 string or None if parsing fails.
    """
    if not date_text:
        return None

    date_text = date_text.strip().lower()

    # Already ISO format
    if re.match(r"\d{4}-\d{2}-\d{2}", date_text):
        return date_text[:19]

    # Clean common noise
    date_text = re.sub(r"(pazartesi|salı|çarşamba|perşembe|cuma|cumartesi|pazar)", "", date_text)
    date_text = re.sub(r"\s+", " ", date_text).strip()

    # Format: "27 Nisan 2026" or "27 Nisan 2026, 14:00"
    match = re.match(
        r"(\d{1,2})\s+(\w+)(?:\s*,?\s*(\d{4}))?(?:\s*,?\s*(\d{1,2})[:\.](\d{2}))?",
        date_text, re.IGNORECASE
    )
    if match:
        day = int(match.group(1))
        month_name = match.group(2).lower()
        year = int(match.group(3)) if match.group(3) else datetime.now().year
        hour = int(match.group(4)) if match.group(4) else 0
        minute = int(match.group(5)) if match.group(5) else 0

        month = TR_MONTHS.get(month_name) or TR_MONTHS_SHORT.get(month_name[:3])
        if month:
            try:
                dt = datetime(year, month, day, hour, minute)
                return dt.isoformat()
            except ValueError:
                pass

    # Format: "Nisan 27, 2026"
    match = re.match(
        r"(\w+)\s+(\d{1,2})(?:\s*,?\s*(\d{4}))?",
        date_text, re.IGNORECASE
    )
    if match:
        month_name = match.group(1).lower()
        day = int(match.group(2))
        year = int(match.group(3)) if match.group(3) else datetime.now().year
        month = TR_MONTHS.get(month_name) or TR_MONTHS_SHORT.get(month_name[:3])
        if month:
            try:
                return datetime(year, month, day).isoformat()
            except ValueError:
                pass

    # Format: "27.04.2026" or "27/04/2026"
    match = re.match(r"(\d{1,2})[./](\d{1,2})[./](\d{4})", date_text)
    if match:
        try:
            dt = datetime(int(match.group(3)), int(match.group(2)), int(match.group(1)))
            return dt.isoformat()
        except ValueError:
            pass

    # Format: "2026-04-27T14:00:00" (already ISO-ish)
    try:
        dt = datetime.fromisoformat(date_text.replace("z", "+00:00"))
        return dt.isoformat()
    except (ValueError, TypeError):
        pass

    logger.warning(f"Could not parse date: {date_text}")
    return None


def detect_category(title: str, description: str = "") -> str:
    """
    Detect event category from title and description using keyword matching.
    Returns the most likely category string.
    """
    combined = f"{title} {description}".lower()

    scores = {}
    for category, keywords in CATEGORY_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in combined)
        if score > 0:
            scores[category] = score

    if scores:
        return max(scores, key=scores.get)

    return "etkinlik"  # Default/generic category


def clean_text(text: str | None) -> str | None:
    """Remove extra whitespace, newlines, and HTML artifacts from text."""
    if not text:
        return None
    # Remove HTML tags if any remain
    text = re.sub(r"<[^>]+>", "", text)
    # Normalize whitespace
    text = re.sub(r"\s+", " ", text).strip()
    return text if text else None


def build_absolute_url(base_url: str, relative_url: str) -> str:
    """Convert a relative URL to absolute using the base URL."""
    if not relative_url:
        return ""
    if relative_url.startswith("http"):
        return relative_url
    if relative_url.startswith("//"):
        return f"https:{relative_url}"
    if relative_url.startswith("/"):
        parsed = urlparse(base_url)
        return f"{parsed.scheme}://{parsed.netloc}{relative_url}"
    return f"{base_url.rstrip('/')}/{relative_url}"


# ─── Wide CSS selectors covering common Turkish municipality CMS layouts ───
EVENT_CARD_SELECTORS = (
    ".etkinlik-item, .event-item, .event-card, "
    ".card, article.post, .list-item, "
    ".etkinlik-liste-item, .etkinlikler-liste .item, "
    "[class*='etkinlik'], [class*='event'], "
    ".col-md-4 .card, .col-lg-4 .card, "
    ".event-list-item, .grid-item, "
    ".news-item, .haber-item, "
    ".calendar-event, .takvim-item"
)

TITLE_SELECTORS = (
    "h2::text, h3::text, h4::text, h5::text, "
    ".title::text, .baslik::text, "
    ".card-title::text, .event-title::text, "
    "a.title::text, .etkinlik-baslik::text"
)

DATE_SELECTORS = (
    ".date::text, .tarih::text, time::text, "
    "time::attr(datetime), span.date::text, "
    ".event-date::text, .card-date::text, "
    ".etkinlik-tarih::text, .calendar-date::text"
)

IMAGE_SELECTORS = (
    "img::attr(src), img::attr(data-src), "
    ".card-img-top::attr(src), "
    "img::attr(data-lazy-src)"
)

DESC_SELECTORS = (
    "p::text, .desc::text, .summary::text, "
    ".card-text::text, .description::text, "
    ".aciklama::text, .ozet::text, .text-content::text, "
    ".news-detail p::text, .entry-content p::text"
)

DETAIL_TITLE_SELECTORS = (
    "h1::text, .page-title::text, .event-title::text, "
    ".detail-title::text, .etkinlik-baslik::text, "
    ".detay-baslik::text, .news-title::text"
)

DETAIL_CONTENT_SELECTORS = (
    ".content p::text, article p::text, "
    ".event-content p::text, .detail-content p::text, "
    ".etkinlik-icerik p::text, .detay-icerik p::text, "
    ".news-content p::text, .entry-content p::text, "
    ".description p::text, .aciklama p::text"
)

LOCATION_SELECTORS = (
    ".location::text, .mekan::text, .yer::text, "
    ".event-location::text, .venue::text, "
    ".adres::text, .salon::text, .address::text"
)

NEXT_PAGE_SELECTORS = (
    "a.next::attr(href), .pagination a[rel='next']::attr(href), "
    "li.next a::attr(href), .page-next a::attr(href), "
    "a[aria-label='Next']::attr(href), "
    "a[aria-label='Sonraki']::attr(href), "
    ".sayfalama a.sonraki::attr(href)"
)

OG_IMAGE_SELECTOR = "meta[property='og:image']::attr(content)"


class BaseEventSpider(scrapy.Spider):
    """
    Abstract base class for municipality event spiders.
    Subclasses must set:
      - name: Spider name (lowercase, no spaces)
      - district: İlçe adı (Turkish)
      - source_name: Source display name
      - start_urls: URLs to crawl
    """
    district = ""
    source_name = ""

    custom_settings = {
        "DOWNLOAD_DELAY": 2,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 1,
        "ROBOTSTXT_OBEY": True,
        "DEFAULT_REQUEST_HEADERS": {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "tr-TR,tr;q=0.9,en;q=0.8",
            "User-Agent": "NexthoodBot/1.0 (+https://github.com/nexthood; Graduation Project)",
        },
    }

    def build_event_item(
        self,
        title: str,
        description: str = "",
        start_date: str = "",
        end_date: str = "",
        location_name: str = "",
        image_url: str = "",
        event_url: str = "",
        is_free: bool = True,
        category: str = "",
    ) -> EventScraperItem:
        """
        Helper to create a standardized EventScraperItem with auto-detected
        category and district coordinates.
        """
        if not category:
            category = detect_category(title, description)

        lat, lng = DISTRICT_COORDINATES.get(self.district, (41.0082, 28.9784))

        item = EventScraperItem()
        item["title"] = clean_text(title) or "Başlıksız Etkinlik"
        item["description"] = clean_text(description)
        
        # Parse dates
        item["start_date"] = parse_turkish_date(start_date)
        
        # Fallback to URL date if start_date is still missing
        if not item["start_date"] and event_url:
            url_date_match = re.search(r"(\d{4})[./-]?(\d{2})[./-]?(\d{2})", event_url)
            if url_date_match:
                item["start_date"] = f"{url_date_match.group(1)}-{url_date_match.group(2)}-{url_date_match.group(3)}T00:00:00"

        item["end_date"] = parse_turkish_date(end_date) if end_date else None
        item["location_name"] = clean_text(location_name) or f"{self.district}, İstanbul"
        item["latitude"] = lat
        item["longitude"] = lng
        item["category"] = category
        item["image_url"] = image_url
        item["event_url"] = event_url
        item["is_free"] = is_free
        item["source_name"] = self.source_name
        item["source_url"] = self.start_urls[0] if self.start_urls else ""
        item["district"] = self.district

        return item

    # ── Generic Parsers (used by most municipality spiders) ──

    def parse(self, response):
        """Default parse: try to extract event cards from listing page."""
        yield from self._parse_listing(response)

    def _parse_listing(self, response):
        """Generic event listing parser covering common CMS layouts."""
        event_cards = response.css(EVENT_CARD_SELECTORS)

        if not event_cards:
            # Fallback: find links that look like event detail pages
            links = response.css('a[href*="etkinlik"]::attr(href)').getall()
            links += response.css('a[href*="event"]::attr(href)').getall()
            seen = set()
            for link in links:
                abs_url = response.urljoin(link)
                if abs_url not in seen and abs_url != response.url:
                    seen.add(abs_url)
                    yield scrapy.Request(abs_url, callback=self._parse_detail)
            return

        for card in event_cards:
            title = card.css(TITLE_SELECTORS).get()
            if not title or not title.strip():
                continue

            link = card.css("a::attr(href)").get()
            date_text = card.css(DATE_SELECTORS).get()
            image = card.css(IMAGE_SELECTORS).get()
            desc = card.css(DESC_SELECTORS).get()

            abs_url = response.urljoin(link) if link else response.url

            yield self.build_event_item(
                title=title,
                description=desc or "",
                start_date=date_text or "",
                location_name=f"{self.district}, İstanbul",
                image_url=build_absolute_url(response.url, image) if image else "",
                event_url=abs_url,
            )

            if link:
                yield scrapy.Request(
                    response.urljoin(link),
                    callback=self._parse_detail,
                    dont_filter=False,
                )

        # Pagination
        next_page = response.css(NEXT_PAGE_SELECTORS).get()
        if next_page:
            yield scrapy.Request(response.urljoin(next_page), callback=self.parse)

    def _parse_detail(self, response):
        """Generic event detail page parser."""
        title = response.css(DETAIL_TITLE_SELECTORS).get()
        if not title:
            # Fallback title from og:title
            title = response.css('meta[property="og:title"]::attr(content)').get()
            if not title:
                return

        description_parts = response.css(DETAIL_CONTENT_SELECTORS).getall()
        description = " ".join([clean_text(p) for p in description_parts if len(clean_text(p)) > 10])
        
        date_text = response.css(DATE_SELECTORS).get()
        location = response.css(LOCATION_SELECTORS).get()
        image = response.css(OG_IMAGE_SELECTOR).get()
        
        if not image:
            image = response.css("article img::attr(src)").get() or response.css(IMAGE_SELECTORS).get()

        yield self.build_event_item(
            title=title,
            description=description,
            start_date=date_text or "",
            location_name=location or f"{self.district}, İstanbul",
            image_url=build_absolute_url(response.url, image) if image else "",
            event_url=response.url,
        )
