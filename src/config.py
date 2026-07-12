from pathlib import Path

DEFAULT_CONFIG = {
    "NOMINATIM_DATABASE_DSN": "sqlite:dbname=nom.sqlite",
    "NOMINATIM_LANGUAGES": "en",
    "NOMINATIM_USE_US_TIGER_DATA": "yes",
    "NOMINATIM_DEFAULT_LANGUAGE": "en",
    "NOMINATIM_LOG_FILE": Path("nominatim.log"),
    "NOMINATIM_QUERY_TIMEOUT": 60,
    "NOMINATIM_REQUEST_TIMEOUT": 120,
}

