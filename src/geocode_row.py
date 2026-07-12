import logging

import pandas as pd

from address_cleaning import normalize_address
from constants import MatchType
from nominatim_geocoder import NominatimGeocoder
from result_scoring import compare_results

logger = logging.getLogger(__name__)


async def geocode_row(
    geocoder: NominatimGeocoder,
    row: pd.Series,
) -> tuple[str, object | None]:
    """Geocode a single address row."""
    if bool(row.get("is_po_box")):
        return MatchType.PO_BOX, None

    addr = normalize_address(row)

    try:
        full_results = await geocoder.search_address(**addr)
        full_result = full_results[0] if full_results else None
    except Exception as e:
        logger.error(f"Full search failed: {e}")
        full_result = None

    street_result = None
    city = row.get("CITY_HX")
    zip_raw = row.get("ZIP_HX")

    city = str(city).strip() if pd.notna(city) else None
    zip_code = str(zip_raw).split("-")[0].strip() if pd.notna(zip_raw) else None

    try:
        if city:
            near = await geocoder.get_city_centroid(city)
            if near:
                street_results = await geocoder.search_address(
                    street=addr["street"], near_query=near
                )
                if street_results:
                    street_result = street_results[0]
    except Exception as e:
        logger.error(f"Street search with city centroid failed: {e}")

    if street_result is None and zip_code:
        try:
            near = await geocoder.get_zip_centroid(zip_code)
            if near:
                street_results = await geocoder.search_address(
                    street=addr["street"], near_query=near
                )
                if street_results:
                    street_result = street_results[0]
        except Exception as e:
            logger.error(f"Street search with zip centroid failed: {e}")

    return compare_results(full_result, street_result, row)

