# Scrapy settings for event_scraper project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     https://docs.scrapy.org/en/latest/topics/settings.html
#     https://docs.scrapy.org/en/latest/topics/downloader-middleware.html
#     https://docs.scrapy.org/en/latest/topics/spider-middleware.html

BOT_NAME = "event_scraper"

SPIDER_MODULES = ["event_scraper.spiders"]
NEWSPIDER_MODULE = "event_scraper.spiders"

ADDONS = {}

# ─── User-Agent ───
USER_AGENT = "NexthoodBot/1.0 (+https://github.com/nexthood; Graduation Project)"

# Obey robots.txt rules
ROBOTSTXT_OBEY = True

# ─── Concurrency & Throttling ───
CONCURRENT_REQUESTS = 8
CONCURRENT_REQUESTS_PER_DOMAIN = 1
DOWNLOAD_DELAY = 2
RANDOMIZE_DOWNLOAD_DELAY = True

# ─── Request Configuration ───
DEFAULT_REQUEST_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept-Encoding": "gzip, deflate",
}

# ─── Retry Configuration ───
RETRY_ENABLED = True
RETRY_TIMES = 3
RETRY_HTTP_CODES = [500, 502, 503, 504, 408, 429]

# ─── Timeout ───
DOWNLOAD_TIMEOUT = 30

# ─── Item Pipelines (execution order by number) ───
ITEM_PIPELINES = {
    "event_scraper.pipelines.CleaningPipeline": 100,
    "event_scraper.pipelines.DuplicateFilterPipeline": 200,
    "event_scraper.pipelines.JsonExportPipeline": 300,
    "event_scraper.pipelines.PostgresPipeline": 400,
}

# ─── AutoThrottle (adaptive rate limiting) ───
AUTOTHROTTLE_ENABLED = True
AUTOTHROTTLE_START_DELAY = 2
AUTOTHROTTLE_MAX_DELAY = 30
AUTOTHROTTLE_TARGET_CONCURRENCY = 1.0
AUTOTHROTTLE_DEBUG = False

# ─── HTTP Cache (for development) ───
# Enable this during development to avoid re-downloading pages
# HTTPCACHE_ENABLED = True
# HTTPCACHE_EXPIRATION_SECS = 3600  # 1 hour
# HTTPCACHE_DIR = "httpcache"
# HTTPCACHE_IGNORE_HTTP_CODES = [500, 502, 503, 504]
# HTTPCACHE_STORAGE = "scrapy.extensions.httpcache.FilesystemCacheStorage"

# ─── Logging ───
LOG_LEVEL = "INFO"
LOG_FORMAT = "%(asctime)s [%(name)s] %(levelname)s: %(message)s"

# ─── Feed Export ───
FEED_EXPORT_ENCODING = "utf-8"

# ─── Spider Middlewares ───
# SPIDER_MIDDLEWARES = {
#     "event_scraper.middlewares.EventScraperSpiderMiddleware": 543,
# }

# ─── Downloader Middlewares ───
# DOWNLOADER_MIDDLEWARES = {
#     "event_scraper.middlewares.EventScraperDownloaderMiddleware": 543,
# }
