import asyncio

import pandas as pd

from address_cleaning import add_po_box_flag
from constants import MatchType, Status
from geocode_row import geocode_row
from nominatim_geocoder import NominatimGeocoder


async def geocode_dataframe(
    df: pd.DataFrame,
    geocoder: NominatimGeocoder,
    max_concurrent_rows: int = 5,
) -> pd.DataFrame:
    """Geocode every row in a DataFrame."""
    df = add_po_box_flag(df.copy())

    row_semaphore = asyncio.Semaphore(max_concurrent_rows)

    async def geocode_one(idx, row):
        async with row_semaphore:
            match_type, result = await geocode_row(geocoder, row)
            return idx, match_type, result

    tasks = [geocode_one(idx, row) for idx, row in df.iterrows()]
    results = await asyncio.gather(*tasks)

    match_types = [""] * len(df)
    statuses = [""] * len(df)

    for idx, match_type, result in results:
        match_types[idx] = match_type

        if match_type == MatchType.PO_BOX:
            statuses[idx] = Status.SKIPPED
        elif match_type == MatchType.UNMATCHED:
            statuses[idx] = Status.FAILED
        else:
            statuses[idx] = Status.SUCCESS

        df.at[idx, "lat"] = getattr(result, "lat", None)
        df.at[idx, "lon"] = getattr(result, "lon", None)
        df.at[idx, "rank_address"] = getattr(result, "rank_address", None)

    df["match_type"] = match_types
    df["geocode_status"] = statuses

    print("\n=== Geocoding Summary ===")
    print(df["match_type"].value_counts())
    print(f"PO Box rows skipped: {df['is_po_box'].sum()}")
    print(f"Total rows: {len(df)}")

    return df

