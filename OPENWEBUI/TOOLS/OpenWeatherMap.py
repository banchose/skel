"""
title: OpenWeatherMap
author: David Williamson - MODIFIED
author_url: https://davidized.com
description: This tool retrieves the current forecast from OpenWeatherMap.
version: 0.2.0
licence: MIT
"""

import json
import logging

import httpx
from pydantic import BaseModel, Field
from typing import Literal

logger = logging.getLogger(__name__)


async def _geocode_location(location: str, email: str) -> tuple[str, str]:
    """Geocode a location string to (lat, lon) via OpenStreetMap Nominatim.

    Uses Nominatim rather than the OpenWeatherMap geocoder because
    Nominatim is more flexible with input formatting.
    """
    geocode_url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": location,
        "limit": 1,
        "format": "jsonv2",
        "email": email,
    }
    headers = {
        "User-Agent": "Open WebUI",
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(geocode_url, params=params, headers=headers)
        response.raise_for_status()
        data = response.json()

    if not data:
        raise ValueError(f"Geocoding returned no results for: {location}")

    return data[0]["lat"], data[0]["lon"]


class Tools:
    """OpenWeatherMap tool for Open WebUI."""

    class Valves(BaseModel):
        api_key: str = Field(
            default="",
            description="OpenWeatherMap API Key",
        )
        units: Literal["imperial", "metric", "standard"] = Field(
            default="standard",
            description="Units to use when returning the weather.",
        )
        email: str = Field(
            default="",
            description="Email address to use when using Nominatim API.",
        )

    def __init__(self):
        self.valves = self.Valves()

    async def get_current_weather(self, location: str, __event_emitter__) -> str:
        """Get an overview of the current weather.

        :param location: The location to get weather for.
        :return: The current weather information or an error message.
        """
        if not self.valves.api_key:
            await __event_emitter__(
                {
                    "type": "notification",
                    "data": {
                        "type": "error",
                        "content": "No OpenWeatherMap API key provided.",
                    },
                }
            )
            return "Valve for OpenWeatherMap API key is not set."

        if not self.valves.email:
            await __event_emitter__(
                {
                    "type": "notification",
                    "data": {
                        "type": "error",
                        "content": "No email address provided.",
                    },
                }
            )
            return "Valve for email is not set."

        try:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Geocoding the location ({location})",
                        "done": False,
                        "hidden": False,
                    },
                }
            )
            lat, lon = await _geocode_location(location, self.valves.email)
        except Exception as e:
            logger.exception("Geocoding failed for %s", location)
            await __event_emitter__(
                {
                    "type": "notification",
                    "data": {
                        "type": "error",
                        "content": f"Failed to geocode location.\n{e}",
                    },
                }
            )
            return f"Error fetching geocoding data: {e}"

        base_url = "https://api.openweathermap.org/data/3.0/onecall"
        params = {
            "lat": lat,
            "lon": lon,
            "appid": self.valves.api_key,
            "units": self.valves.units,
        }

        try:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Retrieving the weather from OpenWeatherMap. ({lat}, {lon})",
                        "done": False,
                        "hidden": False,
                    },
                }
            )

            async with httpx.AsyncClient() as client:
                response = await client.get(base_url, params=params)
                response.raise_for_status()
                data = response.json()

            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": "Weather retrieved successfully.",
                        "done": True,
                        "hidden": False,
                    },
                }
            )

            return json.dumps(data)

        except httpx.HTTPStatusError as e:
            logger.exception("Weather API returned an error")
            await __event_emitter__(
                {
                    "type": "notification",
                    "data": {
                        "type": "error",
                        "content": f"Failed to retrieve weather data.\n{e}",
                    },
                }
            )
            return f"Error fetching weather data: {e}"

        except httpx.RequestError as e:
            logger.exception("Weather API request failed")
            await __event_emitter__(
                {
                    "type": "notification",
                    "data": {
                        "type": "error",
                        "content": f"Failed to retrieve weather data.\n{e}",
                    },
                }
            )
            return f"Error fetching weather data: {e}"
