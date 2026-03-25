"""
title: NASA DONKI Space Weather
author: [your name]
description: Retrieves space weather data from NASA's DONKI system — geomagnetic storms, solar flares, CMEs, and notifications.
version: 0.1.0
licence: MIT
"""

import requests
import json
from datetime import datetime, timedelta
from pydantic import BaseModel, Field
from typing import Literal


class Tools:
    class Valves(BaseModel):
        lookback_days: int = Field(
            default=7,
            description="Default number of days to look back when no date range is specified.",
        )

    def __init__(self):
        self.valves = self.Valves()
        self.base_url = "https://kauai.ccmc.gsfc.nasa.gov/DONKI/WS/get"

    def _default_dates(self, days: int = None) -> tuple[str, str]:
        end = datetime.utcnow()
        start = end - timedelta(days=days or self.valves.lookback_days)
        return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")

    async def get_space_weather_notifications(
        self,
        event_type: str = "all",
        days: int = None,
        __event_emitter__=None,
    ) -> str:
        """
        Get recent space weather notifications from NASA's DONKI system.
        Returns analyst reports on solar flares, CMEs, geomagnetic storms, radiation belt enhancements, and more.
        The messageBody field contains detailed human-readable analysis with causal chains between events.

        :param event_type: Type of event — all, FLR, SEP, CME, IPS, MPC, GST, RBE, or report
        :param days: Number of days to look back (default from valve setting)
        :return: JSON array of space weather notifications
        """
        start_date, end_date = self._default_dates(days)

        if __event_emitter__:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Fetching DONKI {event_type} notifications ({start_date} to {end_date})",
                        "done": False,
                        "hidden": False,
                    },
                }
            )

        params = {
            "startDate": start_date,
            "endDate": end_date,
            "type": event_type,
        }

        try:
            response = requests.get(f"{self.base_url}/notifications", params=params)
            response.raise_for_status()
            data = response.json()

            if __event_emitter__:
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": f"Retrieved {len(data)} notification(s).",
                            "done": True,
                            "hidden": False,
                        },
                    }
                )

            return json.dumps(data, indent=2)

        except requests.RequestException as e:
            if __event_emitter__:
                await __event_emitter__(
                    {
                        "type": "notification",
                        "data": {
                            "type": "error",
                            "content": f"Failed to retrieve DONKI data.\n{str(e)}",
                        },
                    }
                )
            return f"Error fetching DONKI data: {str(e)}"

    async def get_geomagnetic_storms(
        self,
        days: int = None,
        __event_emitter__=None,
    ) -> str:
        """
        Get recent geomagnetic storms with Kp index readings.
        Kp 0-3: quiet. Kp 4: unsettled. Kp 5-6: minor to moderate storm, aurora at mid-latitudes.
        Kp 7-8: strong storm, possible GPS/radio issues. Kp 9: extreme, power grid risk.

        :param days: Number of days to look back (default from valve setting)
        :return: JSON array of geomagnetic storm events with Kp indices and linked causal events
        """
        start_date, end_date = self._default_dates(days)

        if __event_emitter__:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Fetching geomagnetic storm data ({start_date} to {end_date})",
                        "done": False,
                        "hidden": False,
                    },
                }
            )

        params = {"startDate": start_date, "endDate": end_date}

        try:
            response = requests.get(f"{self.base_url}/GST", params=params)
            response.raise_for_status()
            data = response.json()

            if __event_emitter__:
                count = len(data)
                max_kp = 0
                for storm in data:
                    for reading in storm.get("allKpIndex", []):
                        kp = reading.get("kpIndex", 0)
                        if kp > max_kp:
                            max_kp = kp

                desc = f"Retrieved {count} storm(s)."
                if max_kp > 0:
                    desc += f" Max Kp: {max_kp}"

                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": desc,
                            "done": True,
                            "hidden": False,
                        },
                    }
                )

            return json.dumps(data, indent=2)

        except requests.RequestException as e:
            if __event_emitter__:
                await __event_emitter__(
                    {
                        "type": "notification",
                        "data": {
                            "type": "error",
                            "content": f"Failed to retrieve GST data.\n{str(e)}",
                        },
                    }
                )
            return f"Error fetching GST data: {str(e)}"

    async def get_solar_flares(
        self,
        min_class: str = "M",
        days: int = None,
        __event_emitter__=None,
    ) -> str:
        """
        Get recent solar flares. Classes in ascending intensity: A, B, C, M, X.
        M and X class flares are the ones that matter for Earth effects.

        :param min_class: Minimum flare class to return — A, B, C, M, or X (default M)
        :param days: Number of days to look back (default from valve setting)
        :return: JSON array of solar flare events with class, location, and linked events
        """
        start_date, end_date = self._default_dates(days)

        if __event_emitter__:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Fetching solar flares class {min_class}+ ({start_date} to {end_date})",
                        "done": False,
                        "hidden": False,
                    },
                }
            )

        params = {
            "startDate": start_date,
            "endDate": end_date,
            "class": min_class,
        }

        try:
            response = requests.get(f"{self.base_url}/FLR", params=params)
            response.raise_for_status()
            data = response.json()

            if __event_emitter__:
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": f"Retrieved {len(data)} flare(s).",
                            "done": True,
                            "hidden": False,
                        },
                    }
                )

            return json.dumps(data, indent=2)

        except requests.RequestException as e:
            if __event_emitter__:
                await __event_emitter__(
                    {
                        "type": "notification",
                        "data": {
                            "type": "error",
                            "content": f"Failed to retrieve flare data.\n{str(e)}",
                        },
                    }
                )
            return f"Error fetching flare data: {str(e)}"
