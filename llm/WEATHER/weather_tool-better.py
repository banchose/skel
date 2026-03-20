# weather_tool.py
import os
import json
import requests
import datetime


OPENWEATHER_API_KEY = os.environ["OPENWEATHER_APP_ID"]
OPENWEATHER_UNITS = os.environ.get("OPENWEATHER_UNITS", "imperial")
NOMINATIM_EMAIL = os.environ.get("NOMINATIM_EMAIL", "dark.book0043@fastmail.com")
DEFAULT_LAT = os.environ.get("LAT")
DEFAULT_LON = os.environ.get("LON")


def get_current_datetime() -> str:
    """Return the current date, time, and timezone."""
    return datetime.datetime.now().astimezone().strftime("%A, %B %d, %Y %I:%M %p %Z")


def _geocode_location(location: str) -> tuple[float, float]:
    """Geocode a location string to lat/lon using Nominatim."""
    if not NOMINATIM_EMAIL:
        raise EnvironmentError(
            "NOMINATIM_EMAIL environment variable is empty or unset. "
            "Set it to any valid email address (required by Nominatim's usage policy).\n"
            '  export NOMINATIM_EMAIL="you@yourdomain.com"'
        )
    response = requests.get(
        "https://nominatim.openstreetmap.org/search",
        params={
            "q": location,
            "limit": 1,
            "format": "jsonv2",
            "email": NOMINATIM_EMAIL,
        },
        headers={"User-Agent": "llm-weather-tool"},
    )
    response.raise_for_status()
    data = response.json()
    if not data:
        raise ValueError(f"Could not geocode: {location}")
    return float(data[0]["lat"]), float(data[0]["lon"])


def _trim_weather_data(data: dict) -> dict:
    """Pare down the OneCall response to what's actually useful for commentary."""
    trimmed = {}
    if "current" in data:
        trimmed["current"] = data["current"]
    if "alerts" in data:
        trimmed["alerts"] = data["alerts"]
    if "hourly" in data:
        trimmed["hourly_next_12h"] = data["hourly"][:12]
    if "daily" in data:
        trimmed["daily"] = data["daily"]
    for key in ("timezone", "timezone_offset", "lat", "lon"):
        if key in data:
            trimmed[key] = data[key]
    return trimmed


def get_current_weather(location: str = "") -> str:
    """Get the current weather for a location.
    :param location: The location to get weather for (city, address, etc.).
                     If empty, uses the default lat/lon from environment.
    :return: Current weather data as JSON
    """
    if location:
        lat, lon = _geocode_location(location)
    elif DEFAULT_LAT and DEFAULT_LON:
        lat, lon = float(DEFAULT_LAT), float(DEFAULT_LON)
    else:
        return "No location provided and no default LAT/LON set in environment."

    response = requests.get(
        "http://api.openweathermap.org/data/3.0/onecall",
        params={
            "lat": lat,
            "lon": lon,
            "appid": OPENWEATHER_API_KEY,
            "units": OPENWEATHER_UNITS,
        },
    )
    response.raise_for_status()
    data = response.json()
    return json.dumps(_trim_weather_data(data), indent=2)
