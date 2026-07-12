import asyncio
import logging
from typing import Optional

import nominatim_api as napi

from config import DEFAULT_CONFIG

logger = logging.getLogger(__name__)


class NominatimGeocoder:
    """Async geocoder that holds a single Nominatim API session."""

    def __init__(
        self,
        config: dict = DEFAULT_CONFIG,
        max_concurrency: int = 25,
    ):
        self.config = config
        self.api: Optional[napi.NominatimAPIAsync] = None
        self.semaphore = asyncio.Semaphore(max_concurrency)

    async def __aenter__(self) -> "NominatimGeocoder":
        self.api = await napi.NominatimAPIAsync(environ=self.config).__aenter__()
        return self

    async def __aexit__(self, exc_type, exc, tb) -> None:
        if self.api:
            await self.api.__aexit__(exc_type, exc, tb)

    async def search(self, query: str):
        async with self.semaphore:
            return await self.api.search(query)

    async def search_address(
        self,
        *,
        amenity: Optional[str] = None,
        street: Optional[str] = None,
        city: Optional[str] = None,
        county: Optional[str] = None,
        state: Optional[str] = None,
        country: Optional[str] = None,
        postalcode: Optional[str] = None,
        near_query: Optional[str] = None,
    ):
        async with self.semaphore:
            return await self.api.search_address(
                amenity=amenity,
                street=street,
                city=city,
                county=county,
                state=state,
                country=country,
                postalcode=postalcode,
                near_query=near_query,
                addressdetails=1,
            )

    async def get_city_centroid(self, city: str):
        results = await self.search_address(city=city)
        if not results:
            logger.error(f"No city centroid found for: {city}")
            return None

        result = results[0]
        en_tag = result.extratags.get("wikipedia")
        if en_tag:
            state = en_tag.split(", ")[-1]
            city = en_tag.removeprefix("en:").split(",")[0]

            normalized = await self.search_address(city=city, state=state)
            if normalized:
                return normalized[0].centroid

        return result.centroid

    async def get_zip_centroid(self, zip_code: str):
        results = await self.search_address(postalcode=zip_code)
        if results:
            return results[0].centroid

        logger.error(f"No zip centroid found for: {zip_code}")
        return None

