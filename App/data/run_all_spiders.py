"""
Run Istanbul municipality event spiders.
Supports all 40 spiders (39 districts + İBB).

Usage:
    python run_all_spiders.py                    # Run ALL 40 spiders
    python run_all_spiders.py -s kadikoy         # Run single spider
    python run_all_spiders.py -s kadikoy fatih   # Run specific spiders
    python run_all_spiders.py --no-db            # Disable DB, JSON only
    python run_all_spiders.py --list             # List all spiders
"""
import sys
import argparse
import logging
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
)
logger = logging.getLogger("run_all_spiders")


def get_all_spider_names():
    """Import and return all spider names from the registry."""
    from event_scraper.spiders.municipality_spiders import get_all_spider_names as _get
    return _get()


def get_spider_info():
    """Import and return spider info."""
    from event_scraper.spiders.municipality_spiders import get_spider_info as _get
    return _get()


def main():
    parser = argparse.ArgumentParser(
        description="Run Nexthood event scrapers for Istanbul municipalities",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Examples:\n"
               "  python run_all_spiders.py              # Run all 40 spiders\n"
               "  python run_all_spiders.py -s kadikoy   # Run one spider\n"
               "  python run_all_spiders.py --no-db      # JSON export only\n"
               "  python run_all_spiders.py --list       # List all spiders\n",
    )
    parser.add_argument(
        "--spider", "-s",
        nargs="*",
        default=None,
        help="Run specific spider(s). Omit to run all.",
    )
    parser.add_argument(
        "--no-db",
        action="store_true",
        help="Disable PostgreSQL pipeline (JSON export only)",
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all available spiders and exit",
    )
    args = parser.parse_args()

    all_spiders = get_all_spider_names()

    # ── List mode ──
    if args.list:
        info = get_spider_info()
        print(f"\n{'='*70}")
        print(f"  Nexthood Event Scrapers — {len(info)} spiders available")
        print(f"{'='*70}\n")
        print(f"  {'Spider':<20} {'İlçe':<20} {'URL'}")
        print(f"  {'-'*18:<20} {'-'*18:<20} {'-'*30}")
        for s in info:
            print(f"  {s['name']:<20} {s['district']:<20} {s['url']}")
        print()
        sys.exit(0)

    # ── Configure settings ──
    settings = get_project_settings()

    if args.no_db:
        pipelines = dict(settings.get("ITEM_PIPELINES", {}))
        pipelines.pop("event_scraper.pipelines.PostgresPipeline", None)
        settings.set("ITEM_PIPELINES", pipelines)
        logger.info("🚫 PostgreSQL pipeline disabled — JSON export only")

    process = CrawlerProcess(settings)

    # ── Determine which spiders to run ──
    if args.spider:
        targets = args.spider
        # Validate spider names
        invalid = [s for s in targets if s not in all_spiders]
        if invalid:
            logger.error(f"Unknown spider(s): {', '.join(invalid)}")
            logger.info(f"Available: {', '.join(all_spiders)}")
            sys.exit(1)
    else:
        targets = all_spiders

    # ── Crawl ──
    logger.info(f"🕷️  Starting {len(targets)} spider(s)...")
    for spider_name in targets:
        process.crawl(spider_name)

    process.start()
    logger.info(f"✅ All {len(targets)} spider(s) completed!")


if __name__ == "__main__":
    main()
