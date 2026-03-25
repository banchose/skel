# api

Great question — and yes, there's a whole world of affordable API-based **information services** beyond just LLM token pricing. Let me break this into categories, especially thinking about things that would be useful for feeding into an LLM pipeline, powering ambient dashboards, or just having structured data at your fingertips.

---

## News & Event Intelligence (≤$50/mo)

These are *phenomenal* for LLM consumption because they return structured JSON with entities, sentiment, and full article text:

- **Finlight** — Built specifically for financial/geopolitical news. Full article access, sentiment analysis, WebSocket streaming. Free tier with 5,000 req/month, paid plans affordable [6]
- **NewsAPI.ai** — 150,000+ sources, 60+ languages, full-text articles, entity extraction, event clustering, sentiment. Starts at **$90/mo** (just over your budget, but the free tier gives 2,000 tokens with no time limit) [6]
- **NewsData.io** — Multilingual, sentiment analysis, 89 languages. More of a budget option [6]
- **Newsapi.org** — 150,000+ global sources, free tier with 24h delay. Paid at **$449/mo** though — so the free tier is really where the value is for personal use [6]
- **GNews API** — 60,000+ sources, 100 requests/day free [6]

## Weather & Environmental Data (≤$50/mo)

These return clean JSON and are perfect for waybar-style ambient monitoring or LLM context:

- **OpenWeatherMap** — Current weather, forecasts, air quality, UV index. Free tier: 1,000 calls/day. Paid from **~£30/mo** [5]
- **Open-Meteo** — Free for non-commercial, **€29/mo** for commercial. 80 years of historical data, hourly updates. Excellent for LLM pipelines [5]
- **WeatherAPI.com** — 1M free calls/month(!), paid from **$7/mo**. AQI, solar irradiance, marine data [5]
- **Visual Crossing** — 1,000 free calls/day, clean JSON, astronomy data, UV index, historical weather [5]
- **Ambee** — Goes beyond weather into **pollen, wildfire, air quality, natural disasters, and influenza-like illness data**. 15-day trial, custom pricing [5]
- **Stormglass** — Marine-specific: wave height, tides, ocean currents. **€19/mo** [5]

## The "Hidden Gems" Category — Stuff You Probably Didn't Know Had APIs

This is where it gets interesting for LLM consumption and ambient awareness:

- **USGS Earthquake API** — **Free.** Real-time earthquake data globally. Returns structured GeoJSON. You could have a waybar module that lights up when there's a significant quake. Perfect for LLM context injection.
- **National Weather Service API** — **Completely free**, no key needed. US-focused but incredibly detailed. Forecasts, alerts, observations. Government-backed, stable [5]
- **FRED (Federal Reserve Economic Data)** — **Free API.** Hundreds of thousands of economic time series: GDP, unemployment, CPI, interest rates, money supply. Absolute goldmine for an LLM to reason about macroeconomic conditions.
- **NASA APIs** — **Free.** Near-Earth object tracking (asteroids), Mars rover photos, solar flare data (DONKI), Earth imagery. The solar flare/space weather data is actually useful for infrastructure awareness.
- **PurpleAir API** — Hyperlocal air quality from citizen-science sensors. Cheap paid tiers. Fascinating data for health-aware dashboards.
- **Shodan** — Internet-connected device search engine. Membership is a one-time **$49** (not monthly). You can query for exposed devices, monitor internet infrastructure. Unusual but deeply interesting data for security awareness.
- **Have I Been Pwned API** — **Free** for personal use. Monitor whether your email/accounts appear in data breaches. Could feed into a personal security dashboard.
- **OpenSky Network** — **Free.** Live aircraft tracking data. REST API returns all flights in a bounding box. Fun for ambient awareness (what's flying over my house right now?).
- **Wolfram Alpha API** — Computational knowledge engine. Small free tier, paid from **~$5-25/mo**. Fantastic for LLM augmentation — you can offload math, unit conversions, scientific queries, and obscure factual lookups to it.

## Specifically Designed for LLM Consumption

A newer category worth watching:

- **Perplexity Sonar API** — This is a search-augmented LLM API. You send a question, it searches the web and returns a grounded answer with citations. Starts at **$1/1K requests** for the basic tier. It's basically "web search + LLM reasoning" as a single API call [1]
- **Tavily** — Purpose-built search API for AI agents. Optimized for returning clean, structured content that LLMs can consume directly. Free tier, paid from ~$50/mo.
- **Exa (formerly Metaphor)** — Neural search engine with an API. Finds semantically relevant content rather than keyword matches. Free tier available.

---

## My "If I Had $50/mo to Spend on APIs" Stack

If it were me building a personal intelligence pipeline:

| Service | Cost | What it gives you |
|---------|------|-------------------|
| Polygon.io Starter | $29/mo | Financial markets, futures, commodities |
| WeatherAPI.com Pro | $7/mo | Weather + AQI + astronomy |
| FRED API | Free | All US economic indicators |
| USGS Earthquake | Free | Global seismic activity |
| NASA DONKI | Free | Space weather / solar events |
| OpenSky | Free | Live flight tracking |
| Finlight or GNews | Free tier | News with sentiment |
| **Total** | **~$36/mo** | |

That leaves room in the budget for a news upgrade or an occasional Wolfram Alpha call, and you'd have an absurdly comprehensive ambient awareness system — all returning structured data that an LLM can reason about beautifully.

Want me to dig deeper into any of these, or start thinking about how to wire a couple of them into your existing waybar setup?
