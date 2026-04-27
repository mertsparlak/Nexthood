# This package contains the spiders of the Nexthood event_scraper project.
#
# ═══════════════════════════════════════════════════════════════
# 40 Spiders — 39 Istanbul Districts + İBB (Metropolitan)
# ═══════════════════════════════════════════════════════════════
#
# All spiders are auto-generated from DISTRICT_REGISTRY in
# municipality_spiders.py using a factory pattern.
#
# Usage:
#   scrapy list                     # List all available spiders
#   scrapy crawl kadikoy            # Run single spider
#   scrapy crawl ibb                # Run İBB spider
#   python run_all_spiders.py       # Run all 40 spiders
#   python run_all_spiders.py -s fatih   # Run single spider
#   python run_all_spiders.py --no-db    # JSON only (no DB)
#
# Available spiders (alphabetical):
#   ibb, adalar, arnavutkoy, atasehir, avcilar,
#   bagcilar, bahcelievler, bakirkoy, basaksehir, bayrampasa,
#   besiktas, beykoz, beylikduzu, beyoglu, buyukcekmece,
#   catalca, cekmekoy, esenler, esenyurt, eyupsultan,
#   fatih, gaziosmanpasa, gungoren, kadikoy, kagithane,
#   kartal, kucukcekmece, maltepe, pendik, sancaktepe,
#   sariyer, silivri, sultanbeyli, sultangazi, sile,
#   sisli, tuzla, umraniye, uskudar, zeytinburnu
