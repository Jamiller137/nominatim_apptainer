import asyncio
from pathlib import Path

import pandas as pd

from config import DEFAULT_CONFIG
from geocode_dataframe import geocode_dataframe
from nominatim_geocoder import NominatimGeocoder


async def main():
    csv_path = Path("./output.csv")
    data = pd.read_csv(csv_path)
    print(data.head())

    async with NominatimGeocoder(
        config=DEFAULT_CONFIG,
        max_concurrency=10,
    ) as geocoder:
        results = await geocode_dataframe(
            data, geocoder, max_concurrent_rows=1
        )

    return results


if __name__ == "__main__":
    results = asyncio.run(main())
    results.to_csv("./better_geocoded_data.csv", index=False)

