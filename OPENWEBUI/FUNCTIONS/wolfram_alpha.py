import requests
from urllib.parse import quote_plus
from pydantic import BaseModel, Field
from typing import Callable, Awaitable


class Tools:
    class Valves(BaseModel):
        wolframalpha_APP_ID: str = Field(
            default="", description="The App ID (API key) for Wolfram|Alpha"
        )

    def __init__(self):
        self.valves = self.Valves()

    async def perform_query(
        self, query_string: str, __event_emitter__: Callable[[dict], Awaitable[None]]
    ) -> str:
        """
        Query Wolfram|Alpha LLM API with a natural language question.
        Returns computed results optimized for LLM consumption.

        Usage guidelines:
        - Convert queries to simplified English keywords (e.g. "how many people live in France" → "France population").
        - Use exponent notation 6*10^14, never 6e14.
        - Use single-letter variable names (e.g. n, x, n_1).
        - Use named physical constants (e.g. "speed of light"), not numerical values.
        - Include spaces between compound units (e.g. "Ω m").
        - Make separate calls for separate properties.
        - If results seem irrelevant, re-query using Wolfram's suggested assumptions before rephrasing.
        - Format math in responses with $$...$$ (block) or \\(...\\) (inline).

        :param query_string: Natural language query (e.g. "France population", "integrate x^2 dx")
        :return: Wolfram|Alpha response text
        """
        app_id = self.valves.wolframalpha_APP_ID
        if not app_id:
            return "Error: Wolfram|Alpha APP_ID is not set. Configure it in Workspace → Tools → WolframAlpha settings."

        await __event_emitter__(
            {
                "type": "status",
                "data": {
                    "description": f"Querying Wolfram|Alpha: {query_string}",
                    "status": "in_progress",
                    "done": False,
                },
            }
        )

        try:
            url = f"https://www.wolframalpha.com/api/v1/llm-api?input={quote_plus(query_string)}&appid={app_id}&maxchars=6800"
            response = requests.get(url, timeout=30)

            if response.status_code == 200:
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": "Wolfram|Alpha query complete",
                            "status": "complete",
                            "done": True,
                        },
                    }
                )
                return response.text
            else:
                error_msg = f"Wolfram|Alpha returned HTTP {response.status_code}: {response.text}"
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": error_msg,
                            "status": "complete",
                            "done": True,
                        },
                    }
                )
                return error_msg

        except Exception as e:
            error_msg = f"Error querying Wolfram|Alpha: {str(e)}"
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": error_msg,
                        "status": "complete",
                        "done": True,
                    },
                }
            )
            return error_msg
