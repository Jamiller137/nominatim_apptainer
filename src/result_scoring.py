from typing import Optional

import pandas as pd

from constants import MatchType


def _extract_city(address: dict) -> Optional[str]:
    return address.get("city") or address.get("town") or address.get("village")


def _score_result(result, row: pd.Series) -> int:
    address = getattr(result, "address", {}) or {}
    row_zip = str(row.get("ZIP")) if pd.notna(row.get("ZIP")) else None
    row_city = row.get("CITY")

    return sum(
        [
            address.get("postcode") == row_zip,
            _extract_city(address) == row_city,
        ]
    )


def compare_results(
    full_result,
    street_result,
    row: pd.Series,
) -> tuple[str, Optional[object]]:
    """Pick the best geocoding result."""
    full_ok = full_result is not None
    street_ok = street_result is not None

    if full_ok and not street_ok:
        return MatchType.FULL, full_result
    if street_ok and not full_ok:
        return MatchType.STREET, street_result
    if not full_ok and not street_ok:
        return MatchType.UNMATCHED, None

    if full_result.place_id == street_result.place_id:
        return MatchType.FULL, full_result

    full_score = _score_result(full_result, row)
    street_score = _score_result(street_result, row)

    if full_score > street_score:
        return MatchType.FULL, full_result
    if street_score > full_score:
        return MatchType.STREET, street_result

    return MatchType.INCONCLUSIVE, None

