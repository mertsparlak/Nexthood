"""
All 39 Istanbul district municipality spiders + İBB (40 total).
Uses a config-driven factory pattern — each spider inherits from BaseEventSpider
and only differs by name, district, source_name, allowed_domains, and start_urls.

Usage:
    scrapy crawl kadikoy
    scrapy crawl ibb
    scrapy crawl fatih
    ...
"""
from event_scraper.spiders.base_spider import BaseEventSpider


# ═══════════════════════════════════════════════════════════════════════
# District Configuration Registry
# Each entry generates one Spider class at module load time.
# ═══════════════════════════════════════════════════════════════════════
DISTRICT_REGISTRY = {
    # ─── İBB (Metropolitan) ───
    "ibb": {
        "district": "İBB",
        "source_name": "İstanbul Büyükşehir Belediyesi",
        "url": "https://kultursanat.istanbul/etkinliklerimiz",
        "domains": ["kultursanat.istanbul"],
    },
    # ─── A ───
    "adalar": {
        "district": "Adalar",
        "source_name": "Adalar Belediyesi",
        "url": "https://www.adalar.bel.tr/etkinlikler",
        "domains": ["adalar.bel.tr", "www.adalar.bel.tr"],
    },
    "arnavutkoy": {
        "district": "Arnavutköy",
        "source_name": "Arnavutköy Belediyesi",
        "url": "https://www.arnavutkoy.bel.tr/etkinlik-takvimi",
        "domains": ["arnavutkoy.bel.tr", "www.arnavutkoy.bel.tr"],
    },
    "atasehir": {
        "district": "Ataşehir",
        "source_name": "Ataşehir Belediyesi",
        "url": "https://www.atasehir.bel.tr/etkinlikler",
        "domains": ["atasehir.bel.tr", "www.atasehir.bel.tr"],
    },
    "avcilar": {
        "district": "Avcılar",
        "source_name": "Avcılar Belediyesi",
        "url": "https://www.avcilar.bel.tr/etkinlikler",
        "domains": ["avcilar.bel.tr", "www.avcilar.bel.tr"],
    },
    # ─── B ───
    "bagcilar": {
        "district": "Bağcılar",
        "source_name": "Bağcılar Belediyesi",
        "url": "https://www.bagcilar.bel.tr/etkinlikler",
        "domains": ["bagcilar.bel.tr", "www.bagcilar.bel.tr"],
    },
    "bahcelievler": {
        "district": "Bahçelievler",
        "source_name": "Bahçelievler Belediyesi",
        "url": "https://www.bahcelievler.istanbul/etkinlikler",
        "domains": ["bahcelievler.istanbul", "www.bahcelievler.istanbul"],
    },
    "bakirkoy": {
        "district": "Bakırköy",
        "source_name": "Bakırköy Belediyesi",
        "url": "https://www.bakirkoy.bel.tr/etkinliklerimiz",
        "domains": ["bakirkoy.bel.tr", "www.bakirkoy.bel.tr"],
    },
    "basaksehir": {
        "district": "Başakşehir",
        "source_name": "Başakşehir Belediyesi",
        "url": "https://www.basaksehir.bel.tr/etkinlikler",
        "domains": ["basaksehir.bel.tr", "www.basaksehir.bel.tr"],
    },
    "bayrampasa": {
        "district": "Bayrampaşa",
        "source_name": "Bayrampaşa Belediyesi",
        "url": "https://www.bayrampasa.bel.tr/etkinlikler",
        "domains": ["bayrampasa.bel.tr", "www.bayrampasa.bel.tr"],
    },
    "besiktas": {
        "district": "Beşiktaş",
        "source_name": "Beşiktaş Belediyesi",
        "url": "https://besiktas.bel.tr/etkinlikler",
        "domains": ["besiktas.bel.tr"],
    },
    "beykoz": {
        "district": "Beykoz",
        "source_name": "Beykoz Belediyesi",
        "url": "https://www.beykoz.bel.tr/etkinlikler",
        "domains": ["beykoz.bel.tr", "www.beykoz.bel.tr"],
    },
    "beylikduzu": {
        "district": "Beylikdüzü",
        "source_name": "Beylikdüzü Belediyesi",
        "url": "https://www.beylikduzu.istanbul/etkinlikler",
        "domains": ["beylikduzu.istanbul", "www.beylikduzu.istanbul"],
    },
    "beyoglu": {
        "district": "Beyoğlu",
        "source_name": "Beyoğlu Belediyesi",
        "url": "https://beyoglu.bel.tr/etkinlikler",
        "domains": ["beyoglu.bel.tr"],
    },
    "buyukcekmece": {
        "district": "Büyükçekmece",
        "source_name": "Büyükçekmece Belediyesi",
        "url": "https://www.bcekmece.bel.tr/etkinlikler",
        "domains": ["bcekmece.bel.tr", "www.bcekmece.bel.tr"],
    },
    # ─── C / Ç ───
    "catalca": {
        "district": "Çatalca",
        "source_name": "Çatalca Belediyesi",
        "url": "https://www.catalca.bel.tr/etkinlikler",
        "domains": ["catalca.bel.tr", "www.catalca.bel.tr"],
    },
    "cekmekoy": {
        "district": "Çekmeköy",
        "source_name": "Çekmeköy Belediyesi",
        "url": "https://www.cekmekoy.bel.tr/etkinlikler",
        "domains": ["cekmekoy.bel.tr", "www.cekmekoy.bel.tr"],
    },
    # ─── E ───
    "esenler": {
        "district": "Esenler",
        "source_name": "Esenler Belediyesi",
        "url": "https://esenler.bel.tr/kultur-sanat/etkinlikler/",
        "domains": ["esenler.bel.tr"],
    },
    "esenyurt": {
        "district": "Esenyurt",
        "source_name": "Esenyurt Belediyesi",
        "url": "https://www.esenyurt.bel.tr/etkinlikler",
        "domains": ["esenyurt.bel.tr", "www.esenyurt.bel.tr"],
    },
    "eyupsultan": {
        "district": "Eyüpsultan",
        "source_name": "Eyüpsultan Belediyesi",
        "url": "https://www.eyupsultan.bel.tr/tr/main/eventcalendar",
        "domains": ["eyupsultan.bel.tr", "www.eyupsultan.bel.tr"],
    },
    # ─── F ───
    "fatih": {
        "district": "Fatih",
        "source_name": "Fatih Belediyesi",
        "url": "https://www.fatih.bel.tr/tr/main/eventcalendar",
        "domains": ["fatih.bel.tr", "www.fatih.bel.tr"],
    },
    # ─── G ───
    "gaziosmanpasa": {
        "district": "Gaziosmanpaşa",
        "source_name": "Gaziosmanpaşa Belediyesi",
        "url": "https://www.gaziosmanpasa.bel.tr/etkinlikler",
        "domains": ["gaziosmanpasa.bel.tr", "www.gaziosmanpasa.bel.tr"],
    },
    "gungoren": {
        "district": "Güngören",
        "source_name": "Güngören Belediyesi",
        "url": "https://www.gungoren.bel.tr/etkinlikler",
        "domains": ["gungoren.bel.tr", "www.gungoren.bel.tr"],
    },
    # ─── K ───
    "kadikoy": {
        "district": "Kadıköy",
        "source_name": "Kadıköy Belediyesi",
        "url": "https://www.kadikoy.bel.tr/etkinlikler",
        "domains": ["kadikoy.bel.tr", "www.kadikoy.bel.tr"],
    },
    "kagithane": {
        "district": "Kağıthane",
        "source_name": "Kağıthane Belediyesi",
        "url": "https://www.kagithane.istanbul/etkinlikler",
        "domains": ["kagithane.istanbul", "www.kagithane.istanbul"],
    },
    "kartal": {
        "district": "Kartal",
        "source_name": "Kartal Belediyesi",
        "url": "https://www.kartal.bel.tr/etkinlikler",
        "domains": ["kartal.bel.tr", "www.kartal.bel.tr"],
    },
    "kucukcekmece": {
        "district": "Küçükçekmece",
        "source_name": "Küçükçekmece Belediyesi",
        "url": "https://kucukcekmece.bel.tr/etkinlik-takvimi",
        "domains": ["kucukcekmece.bel.tr"],
    },
    # ─── M ───
    "maltepe": {
        "district": "Maltepe",
        "source_name": "Maltepe Belediyesi",
        "url": "https://www.maltepe.bel.tr/etkinlikler",
        "domains": ["maltepe.bel.tr", "www.maltepe.bel.tr"],
    },
    # ─── P ───
    "pendik": {
        "district": "Pendik",
        "source_name": "Pendik Belediyesi",
        "url": "https://www.pendik.bel.tr/etkinlikler",
        "domains": ["pendik.bel.tr", "www.pendik.bel.tr"],
    },
    # ─── S / Ş ───
    "sancaktepe": {
        "district": "Sancaktepe",
        "source_name": "Sancaktepe Belediyesi",
        "url": "https://www.sancaktepe.bel.tr/etkinlikler",
        "domains": ["sancaktepe.bel.tr", "www.sancaktepe.bel.tr"],
    },
    "sariyer": {
        "district": "Sarıyer",
        "source_name": "Sarıyer Belediyesi",
        "url": "https://sariyer.bel.tr/Etkinlikler",
        "domains": ["sariyer.bel.tr"],
    },
    "silivri": {
        "district": "Silivri",
        "source_name": "Silivri Belediyesi",
        "url": "https://www.silivri.bel.tr/etkinlikler",
        "domains": ["silivri.bel.tr", "www.silivri.bel.tr"],
    },
    "sultanbeyli": {
        "district": "Sultanbeyli",
        "source_name": "Sultanbeyli Belediyesi",
        "url": "https://www.sultanbeyli.bel.tr/etkinlikler",
        "domains": ["sultanbeyli.bel.tr", "www.sultanbeyli.bel.tr"],
    },
    "sultangazi": {
        "district": "Sultangazi",
        "source_name": "Sultangazi Belediyesi",
        "url": "https://www.sultangazi.bel.tr/etkinlikler",
        "domains": ["sultangazi.bel.tr", "www.sultangazi.bel.tr"],
    },
    "sile": {
        "district": "Şile",
        "source_name": "Şile Belediyesi",
        "url": "https://www.sile.bel.tr/etkinlikler",
        "domains": ["sile.bel.tr", "www.sile.bel.tr"],
    },
    "sisli": {
        "district": "Şişli",
        "source_name": "Şişli Belediyesi",
        "url": "https://www.sisli.bel.tr/etkinlikler",
        "domains": ["sisli.bel.tr", "www.sisli.bel.tr"],
    },
    # ─── T ───
    "tuzla": {
        "district": "Tuzla",
        "source_name": "Tuzla Belediyesi",
        "url": "https://www.tuzla.bel.tr/etkinlikler",
        "domains": ["tuzla.bel.tr", "www.tuzla.bel.tr"],
    },
    # ─── Ü ───
    "umraniye": {
        "district": "Ümraniye",
        "source_name": "Ümraniye Belediyesi",
        "url": "https://www.umraniye.bel.tr/tr/main/eventcalendar",
        "domains": ["umraniye.bel.tr", "www.umraniye.bel.tr"],
    },
    "uskudar": {
        "district": "Üsküdar",
        "source_name": "Üsküdar Belediyesi",
        "url": "https://uskudarkultursanat.com/",
        "domains": ["uskudarkultursanat.com"],
    },
    # ─── Z ───
    "zeytinburnu": {
        "district": "Zeytinburnu",
        "source_name": "Zeytinburnu Belediyesi",
        "url": "https://www.zeytinburnu.istanbul/Etkinlikler",
        "domains": ["zeytinburnu.istanbul", "www.zeytinburnu.istanbul"],
    },
}


# ═══════════════════════════════════════════════════════════════════════
# Dynamic Spider Class Factory
# Generates one Spider class per district at import time.
# All spider classes are registered in the module namespace so Scrapy
# can discover them via its standard SPIDER_MODULES mechanism.
# ═══════════════════════════════════════════════════════════════════════

def _create_spider_class(spider_name: str, config: dict) -> type:
    """
    Dynamically create a Spider class from a config dictionary.
    Returns a new class that inherits from BaseEventSpider.
    """
    class_name = f"{spider_name.capitalize()}Spider"

    attrs = {
        "name": spider_name,
        "district": config["district"],
        "source_name": config["source_name"],
        "allowed_domains": config["domains"],
        "start_urls": [config["url"]],
    }

    return type(class_name, (BaseEventSpider,), attrs)


# Generate all spider classes and register them in this module's namespace
_generated_spiders = {}
for _name, _config in DISTRICT_REGISTRY.items():
    _spider_cls = _create_spider_class(_name, _config)
    _generated_spiders[_name] = _spider_cls
    # Register in module globals so Scrapy can find them
    globals()[_spider_cls.__name__] = _spider_cls


def get_all_spider_names() -> list[str]:
    """Return all registered spider names sorted alphabetically."""
    return sorted(DISTRICT_REGISTRY.keys())


def get_spider_info() -> list[dict]:
    """Return info about all registered spiders."""
    return [
        {
            "name": name,
            "district": config["district"],
            "source_name": config["source_name"],
            "url": config["url"],
        }
        for name, config in sorted(DISTRICT_REGISTRY.items())
    ]
