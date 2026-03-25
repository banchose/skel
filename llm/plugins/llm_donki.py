# llm_donki.py (plugin entry point)
import llm
import requests
import json
from datetime import datetime, timedelta

BASE_URL = "https://kauai.ccmc.gsfc.nasa.gov/DONKI/WS/get"


def _date_range(days=7):
    end = datetime.utcnow()
    start = end - timedelta(days=days)
    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")


@llm.hookimpl
def register_tools(register):
    register(get_space_weather_notifications)
    register(get_geomagnetic_storms)
    register(get_solar_flares)


# ... same function definitions as above ...


def _date_range(days: int = None) -> tuple[str, str]:
    end = datetime.utcnow()
    start = end - timedelta(days=days or DEFAULT_LOOKBACK)
    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")


def get_space_weather_notifications(event_type: str = "all", days: int = 7) -> str:
    """Get recent space weather notifications from NASA DONKI.
    Returns analyst reports on solar flares, CMEs, geomagnetic storms, and more.
    The messageBody field contains detailed human-readable analysis with causal chains.

    :param event_type: Type — all, FLR, SEP, CME, IPS, MPC, GST, RBE, or report
    :param days: Number of days to look back
    """
    start, end = _date_range(days)
    resp = requests.get(
        f"{BASE_URL}/notifications",
        params={"startDate": start, "endDate": end, "type": event_type},
    )
    resp.raise_for_status()
    return json.dumps(resp.json(), indent=2)


def get_geomagnetic_storms(days: int = 7) -> str:
    """Get recent geomagnetic storms with Kp index readings from NASA DONKI.
    Kp 0-3: quiet. 4: unsettled. 5-6: minor/moderate storm. 7-8: strong. 9: extreme.

    :param days: Number of days to look back
    """
    start, end = _date_range(days)
    resp = requests.get(f"{BASE_URL}/GST", params={"startDate": start, "endDate": end})
    resp.raise_for_status()
    return json.dumps(resp.json(), indent=2)


def get_solar_flares(min_class: str = "M", days: int = 7) -> str:
    """Get recent solar flares from NASA DONKI.
    Classes ascending: A, B, C, M, X. M and X have Earth-facing consequences.

    :param min_class: Minimum flare class — A, B, C, M, or X
    :param days: Number of days to look back
    """
    start, end = _date_range(days)
    resp = requests.get(
        f"{BASE_URL}/FLR",
        params={"startDate": start, "endDate": end, "class": min_class},
    )
    resp.raise_for_status()
    return json.dumps(resp.json(), indent=2)
