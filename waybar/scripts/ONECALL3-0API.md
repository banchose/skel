## Product concept

Get essential weather data, short-term and long-term forecasts and aggregated weather data is easy with our OpenWeather **One Call API 3.0**. This product designed to ensure [easy migration from the Dark Sky API](https://openweathermap.org/darksky-openweather-3).

One Call API 3.0 contains 4 endpoints and provides access to various data:

- [**Current weather and forecasts:**](#current)
    - minute forecast for 1 hour
    - hourly forecast for 48 hours
    - daily forecast for 8 daysand government weather alerts
- [**Weather data for any timestamp**](#history) for 46+ years historical archive and 4 days ahead forecast
- [**Daily aggregation**](#history_daily_aggregation) of weather data for 46+ years archive and 1.5 years ahead forecast
- [**Weather overview**](#weather_overview) with a human-readable weather summary for today and tomorrow's forecast, utilizing OpenWeather AI technologies

One Call API 3.0 is based on the proprietary [OpenWeather Model](https://openweather.co.uk/technology) and is updated every 10 minutes. Thus, in order to receive the most accurate and up-to-date weather data, we recommend you request One Call API 3.0 every 10 minutes.

Please note, that One Call API 3.0 is included in the ["One Call by Call"](https://openweathermap.org/price) subscription **only**. This separate subscription includes 1,000 calls/day for free and allows you to pay only for the number of API calls made to this product. Please note, that you do not need to subscribe to any other OpenWeather subscription plans to get access to the One Call API 3.0. Please find more details on the [pricing page](https://openweathermap.org/price) and [FAQ](https://openweathermap.org/faq#onecall) or ask [Ulla, OpenWeather AI assistant](https://openweathermap.org/chat).

## How to start

1.  [Sign up](https://home.openweathermap.org/users/sign_up) to OpenWeather service in case you haven't got your [OpenWeather API key](https://home.openweathermap.org/api_keys) yet.
2.  Follow the [pricing page](https://openweathermap.org/price#onecall) to learn details about the price.
    
    One Call API 3.0 is included in the separate subscription only and allows you to pay only for the number of API calls made to this product. Please find more details on the [pricing page](https://openweathermap.org/price#onecall).
    
3.  Once you subscribe to One call API 3.0, 2000 API calls per day to this product are set up by default. If you want to change this limit, please go to the ["Billing plans" tab](https://home.openweathermap.org/subscriptions) in your Personal account to update standard settings. You can find more information on the [FAQ](https://openweathermap.org/faq#onecall) or ask [Ulla, OpenWeather AI assistant](https://openweathermap.org/chat).
4.  Select the desired type of data ([Current and forecasts weather data](#current), [Weather data for timestamp](#history), [Daily aggregation](#history_daily_aggregation), [Weather overview](#weather_overview)) and make an API call according to relevant tech documentation section, remembering to add your key to each call.

## Current and forecasts weather data

To get access to current weather, minute forecast for 1 hour, hourly forecast for 48 hours, daily forecast for 8 days and government weather alerts, please use this section of the documentation.

If you are interested in other functionality on One Call API 3.0, please check [Product concept](https://openweathermap.org/api/one-call-3#concept) to follow the right section.

### How to make an API call

`https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&exclude={part}&appid=[{API key}](https://home.openweathermap.org/api_keys)`

<div class="joplin-table-wrapper"><table><tbody><tr><th colspan="3">Parameters</th></tr><tr><td><code>lat</code></td><td>required</td><td>Latitude, decimal (-90; 90). If you need the geocoder to automatic convert city names and zip-codes to geo coordinates and the other way around, please use our <a href="https://openweathermap.org/api/geocoding-api">Geocoding API</a></td></tr><tr><td><code>lon</code></td><td>required</td><td>Longitude, decimal (-180; 180). If you need the geocoder to automatic convert city names and zip-codes to geo coordinates and the other way around, please use our <a href="https://openweathermap.org/api/geocoding-api">Geocoding API</a></td></tr><tr><td><code>appid</code></td><td>required</td><td>Your unique API key (you can always find it on your account page under the <a href="https://home.openweathermap.org/api_keys" target="_blank">"API key" tab</a>)</td></tr><tr><td><code>exclude</code></td><td>optional</td><td>By using this parameter you can exclude some parts of the weather data from the API response. It should be a comma-delimited list (without spaces).<p>Available values:</p><ul><li><code>current</code></li><li><code>minutely</code></li><li><code>hourly</code></li><li><code>daily</code></li><li><code>alerts</code></li></ul></td></tr><tr><td><code>units</code></td><td>optional</td><td>Units of measurement. <code>standard</code>, <code>metric</code> and <code>imperial</code> units are available. If you do not use the <code>units</code> parameter, <code>standard</code> units will be applied by default. <a href="#data">Learn more</a></td></tr><tr><td><code>lang</code></td><td><span>optional</span></td><td>You can use the <code>lang</code> parameter to get the output in your language. <a href="#multi">Learn more</a></td></tr></tbody></table></div>

Before making an API call, please note, that One Call 3.0 is included in the "One Call by Call" subscription **only**. [Learn more](https://openweathermap.org/price)

If you you want to exclude some parts of the weather data from the API response please add `exclude` parameter to the API call like in the example below:

`https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&exclude=hourly,daily&appid=[{API key}](https://home.openweathermap.org/api_keys)`

If you do not need to exclude any of the weather data from the API response please use API call like in the example below:

`https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&appid=[{API key}](https://home.openweathermap.org/api_keys)`

                `{   "lat":33.44,   "lon":-94.04,   "timezone":"America/Chicago",   "timezone_offset":-18000,   "current":{      "dt":1684929490,      "sunrise":1684926645,      "sunset":1684977332,      "temp":292.55,      "feels_like":292.87,      "pressure":1014,      "humidity":89,      "dew_point":290.69,      "uvi":0.16,      "clouds":53,      "visibility":10000,      "wind_speed":3.13,      "wind_deg":93,      "wind_gust":6.71,      "weather":[         {            "id":803,            "main":"Clouds",            "description":"broken clouds",            "icon":"04d"         }      ]   },   "minutely":[      {         "dt":1684929540,         "precipitation":0      },      ...   ],   "hourly":[      {         "dt":1684926000,         "temp":292.01,         "feels_like":292.33,         "pressure":1014,         "humidity":91,         "dew_point":290.51,         "uvi":0,         "clouds":54,         "visibility":10000,         "wind_speed":2.58,         "wind_deg":86,         "wind_gust":5.88,         "weather":[            {               "id":803,               "main":"Clouds",               "description":"broken clouds",               "icon":"04n"            }         ],         "pop":0.15      },      ...   ],   "daily":[      {         "dt":1684951200,         "sunrise":1684926645,         "sunset":1684977332,         "moonrise":1684941060,         "moonset":1684905480,         "moon_phase":0.16,         "summary":"Expect a day of partly cloudy with rain",         "temp":{            "day":299.03,            "min":290.69,            "max":300.35,            "night":291.45,            "eve":297.51,            "morn":292.55         },         "feels_like":{            "day":299.21,            "night":291.37,            "eve":297.86,            "morn":292.87         },         "pressure":1016,         "humidity":59,         "dew_point":290.48,         "wind_speed":3.98,         "wind_deg":76,         "wind_gust":8.92,         "weather":[            {               "id":500,               "main":"Rain",               "description":"light rain",               "icon":"10d"            }         ],         "clouds":92,         "pop":0.47,         "rain":0.15,         "uvi":9.23      },      ...   ],    "alerts": [    {      "sender_name": "NWS Philadelphia - Mount Holly (New Jersey, Delaware, Southeastern Pennsylvania)",      "event": "Small Craft Advisory",      "start": 1684952747,      "end": 1684988747,      "description": "...SMALL CRAFT ADVISORY REMAINS IN EFFECT FROM 5 PM THIS\nAFTERNOON TO 3 AM EST FRIDAY...\n* WHAT...North winds 15 to 20 kt with gusts up to 25 kt and seas\n3 to 5 ft expected.\n* WHERE...Coastal waters from Little Egg Inlet to Great Egg\nInlet NJ out 20 nm, Coastal waters from Great Egg Inlet to\nCape May NJ out 20 nm and Coastal waters from Manasquan Inlet\nto Little Egg Inlet NJ out 20 nm.\n* WHEN...From 5 PM this afternoon to 3 AM EST Friday.\n* IMPACTS...Conditions will be hazardous to small craft.",      "tags": [      ]    },    ...  ]                `
                
              

If you do not see some of the parameters in your API response it means that these weather phenomena are just not happened for the time of measurement for the city or location chosen. Only really measured or calculated data is displayed in API response.

- `lat` Latitude of the location, decimal (−90; 90)
- `lon` Longitude of the location, decimal (-180; 180)
- `timezone` Timezone name for the requested location
- `timezone_offset` Shift in seconds from UTC
- `current` **Current weather data API response**
    - `current.dt` Current time, Unix, UTC
    - `current.sunrise` Sunrise time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `current.sunset` Sunset time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `current.temp` Temperature. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `current.feels_like` Temperature. This temperature parameter accounts for the human perception of weather. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `current.pressure` Atmospheric pressure on the sea level, hPa
    - `current.humidity` Humidity, %
    - `current.dew_point` Atmospheric temperature (varying according to pressure and humidity) below which water droplets begin to condense and dew can form. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit
    - `current.clouds` Cloudiness, %
    - `current.uvi` Current UV index.
    - `current.visibility` Average visibility, metres. The maximum value of the visibility is 10 km
    - `current.wind_speed` Wind speed. Wind speed. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `current.wind_gust` (where available) Wind gust. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `current.wind_deg` Wind direction, degrees (meteorological)
    - `current.rain`
        - `current.rain.1h` (where available) Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
    - `current.snow`
        - `current.snow.1h` (where available) Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
    - `current.weather`
        - `current.weather.id` [Weather condition id](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)
        - `current.weather.main` Group of weather parameters (Rain, Snow etc.)
        - `current.weather.description` Weather condition within the group ([full list of weather conditions](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)). Get the output in [your language](#multi)
        - `current.weather.icon` Weather icon id. [How to get icons](https://openweathermap.org/weather-conditions#How-to-get-icon-URL)
- `minutely` **Minute forecast weather data API response**
    - `minutely.dt` Time of the forecasted data, unix, UTC
    - `minutely.precipitation` Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
- `hourly` **Hourly forecast weather data API response**
    - `hourly.dt` Time of the forecasted data, Unix, UTC
    - `hourly.temp` Temperature. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `hourly.feels_like` Temperature. This accounts for the human perception of weather. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `hourly.pressure` Atmospheric pressure on the sea level, hPa
    - `hourly.humidity` Humidity, %
    - `hourly.dew_point` Atmospheric temperature (varying according to pressure and humidity) below which water droplets begin to condense and dew can form. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `hourly.uvi` UV index
    - `hourly.clouds` Cloudiness, %
    - `hourly.visibility` Average visibility, metres. The maximum value of the visibility is 10 km
    - `hourly.wind_speed` Wind speed. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour.[How to change units used](#data)
    - `hourly.wind_gust` (where available) Wind gust. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `hourly.wind_deg` Wind direction, degrees (meteorological)
    - `hourly.pop` Probability of precipitation. The values of the parameter vary between 0 and 1, where 0 is equal to 0%, 1 is equal to 100%
    - `hourly.rain`
        - `hourly.rain.1h` (where available) Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
    - `hourly.snow`
        - `hourly.snow.1h` (where available) Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
    - `hourly.weather`
        - `hourly.weather.id` [Weather condition id](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)
        - `hourly.weather.main` Group of weather parameters (Rain, Snow etc.)
        - `hourly.weather.description` Weather condition within the group ([full list of weather conditions](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)). Get the output in [your language](#multi)
        - `hourly.weather.icon` Weather icon id. [How to get icons](https://openweathermap.org/weather-conditions#How-to-get-icon-URL)
- `daily` **Daily forecast weather data API response**
    - `daily.dt` Time of the forecasted data, Unix, UTC
    - `daily.sunrise` Sunrise time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `daily.sunset` Sunset time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `daily.moonrise` The time of when the moon rises for this day, Unix, UTC
    - `daily.moonset` The time of when the moon sets for this day, Unix, UTC
    - `daily.moon_phase` Moon phase. `0` and `1` are 'new moon', `0.25` is 'first quarter moon', `0.5` is 'full moon' and `0.75` is 'last quarter moon'. The periods in between are called 'waxing crescent', 'waxing gibbous', 'waning gibbous', and 'waning crescent', respectively. Moon phase calculation algorithm: if the moon phase values between the start of the day and the end of the day have a round value (0, 0.25, 0.5, 0.75, 1.0), then this round value is taken, otherwise the average of moon phases for the start of the day and the end of the day is taken
    - `summary`Human-readable description of the weather conditions for the day
    - `daily.temp` Units – default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
        - `daily.temp.morn` Morning temperature.
        - `daily.temp.day` Day temperature.
        - `daily.temp.eve` Evening temperature.
        - `daily.temp.night` Night temperature.
        - `daily.temp.min` Min daily temperature.
        - `daily.temp.max` Max daily temperature.
    - `daily.feels_like` This accounts for the human perception of weather. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
        - `daily.feels_like.morn` Morning temperature.
        - `daily.feels_like.day` Day temperature.
        - `daily.feels_like.eve` Evening temperature.
        - `daily.feels_like.night` Night temperature.
    - `daily.pressure` Atmospheric pressure on the sea level, hPa
    - `daily.humidity` Humidity, %
    - `daily.dew_point` Atmospheric temperature (varying according to pressure and humidity) below which water droplets begin to condense and dew can form. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `daily.wind_speed` Wind speed. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `daily.wind_gust` (where available) Wind gust. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `daily.wind_deg` Wind direction, degrees (meteorological)
    - `daily.clouds` Cloudiness, %
    - `daily.uvi` The maximum value of UV index for the day
    - `daily.pop` Probability of precipitation. The values of the parameter vary between 0 and 1, where 0 is equal to 0%, 1 is equal to 100%
    - `daily.rain` (where available) Precipitation volume, mm. Please note that only mm as units of measurement are available for this parameter
    - `daily.snow` (where available) Snow volume, mm. Please note that only mm as units of measurement are available for this parameter
    - `daily.weather`
        - `daily.weather.id` [Weather condition id](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)
        - `daily.weather.main` Group of weather parameters (Rain, Snow etc.)
        - `daily.weather.description` Weather condition within the group ([full list of weather conditions](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)). Get the output in [your language](#multi)
        - `daily.weather.icon` Weather icon id. [How to get icons](https://openweathermap.org/weather-conditions#How-to-get-icon-URL)
- `alerts` **National weather alerts data from major national weather warning systems**
    - `alerts.sender_name` Name of the alert source. Please read here the [full list of alert sources](#listsource)
    - `alerts.event` Alert event name
    - `alerts.start` Date and time of the start of the alert, Unix, UTC
    - `alerts.end` Date and time of the end of the alert, Unix, UTC
    - `alerts.description` Description of the alert
    - `alerts.tags` Type of severe weather

National weather alerts are provided in English by default.  
Please note that some agencies provide the alert’s description only in a local language.

## Weather data for timestamp

To learn about how get access to weather data for any timestamp from 1st January 1979 till 4 days ahead forecast, please use this section of the documentation.

If you are interested in other functionality on One Call API 3.0, please check [Product concept](https://openweathermap.org/api/one-call-3#concept) to follow the right section.

### How to make an API call

`https://api.openweathermap.org/data/3.0/onecall/timemachine?lat={lat}&lon={lon}&dt={time}&appid=[{API key}](https://home.openweathermap.org/api_keys)`

| Parameters |     |     |
| --- |     |     | --- | --- |
| `lat` | required | Latitude, decimal (-90; 90). If you need the geocoder to automatic convert city names and zip-codes to geo coordinates and the other way around, please use our [Geocoding API](https://openweathermap.org/api/geocoding-api) |
| `lon` | required | Longitude, decimal (-180; 180). If you need the geocoder to automatic convert city names and zip-codes to geo coordinates and the other way around, please use our [Geocoding API](https://openweathermap.org/api/geocoding-api) |
| `dt` | required | Timestamp (Unix time, UTC time zone), e.g. dt=1586468027. Data is available **from January 1st, 1979 till 4 days ahead** |
| `appid` | required | Your unique API key (you can always find it on your account page under the ["API key" tab](https://home.openweathermap.org/api_keys)) |
| `units` | optional | Units of measurement. `standard`, `metric` and `imperial` units are available. If you do not use the `units` parameter, `standard` units will be applied by default. [Learn more](#data) |
| `lang` | optional | You can use the `lang` parameter to get the output in your language. [Learn more](#multi) |

Please note that the one API response contains weather data for only one specified timestamp.

Before making an API call, please note, that One Call 3.0 is included in the "One Call by Call" subscription **only**. [Learn more](https://openweathermap.org/price)

`https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=39.099724&lon=-94.578331&dt=1643803200&appid=[{API key}](https://home.openweathermap.org/api_keys)`

                   `   {  "lat": 52.2297,  "lon": 21.0122,  "timezone": "Europe/Warsaw",  "timezone_offset": 3600,  "data": [    {      "dt": 1645888976,      "sunrise": 1645853361,      "sunset": 1645891727,      "temp": 279.13,      "feels_like": 276.44,      "pressure": 1029,      "humidity": 64,      "dew_point": 272.88,      "uvi": 0.06,      "clouds": 0,      "visibility": 10000,      "wind_speed": 3.6,      "wind_deg": 340,      "weather": [        {          "id": 800,          "main": "Clear",          "description": "clear sky",          "icon": "01d"        }      ]    }  ]}                    `
                   
                 

If you do not see some of the parameters in your API response it means that these weather phenomena are just not happened for the time of measurement for the city or location chosen. Only really measured or calculated data is displayed in API response.

- `lat` Latitude of the location, decimal (−90; 90)
- `lon` Longitude of the location, decimal (-180; 180)
- `timezone` Timezone name for the requested location
- `timezone_offset` Shift in seconds from UTC
- `data`
    - `data.dt` Requested time, Unix, UTC
    - `data.sunrise` Sunrise time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `data.sunset` Sunset time, Unix, UTC. For polar areas in midnight sun and polar night periods this parameter is not returned in the response
    - `data.temp` Temperature. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `data.feels_like` Temperature. This accounts for the human perception of weather. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `data.pressure` Atmospheric pressure on the sea level, hPa
    - `data.humidity` Humidity, %
    - `data.dew_point` Atmospheric temperature (varying according to pressure and humidity) below which water droplets begin to condense and dew can form. Units – default: kelvin, metric: Celsius, imperial: Fahrenheit.
    - `data.clouds` Cloudiness, %
    - `data.uvi` UV index. Please pay attention that historical UV index data available only for 5 days back. If you would like to get historical UVI index data starting from 20th September 2020 please [contact us](mailto:info@openweathermap.org)
    - `data.visibility` Average visibility, metres. The maximum value of the visibility is 10 km
    - `data.wind_speed` Wind speed. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `data.wind_gust` (where available) Wind gust. Wind speed. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
    - `data.wind_deg` Wind direction, degrees (meteorological)
    - `data.weather`
        - `data.weather.id` [Weather condition id](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)
        - `data.weather.main` Group of weather parameters (Rain, Snow etc.)
        - `data.weather.description` Weather condition within the group ([full list of weather conditions](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2)). Get the output in [your language](#multi)
        - `data.weather.icon` Weather icon id. [How to get icons](https://openweathermap.org/weather-conditions#How-to-get-icon-URL)
    - `data.rain` (where available)
        - `1h` Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter
    - `data.snow`(where available)
        - `1h` Precipitation, mm/h. Please note that only mm/h as units of measurement are available for this parameter

## Daily Aggregation

To learn about how get access to aggregated weather data for a particular date from 2nd January 1979 till long-term forecast for 1,5 years ahead, please use this section of the documentation.

If you are interested in other functionality on One Call API 3.0, please check [Product concept](https://openweathermap.org/api/one-call-3#concept) to follow the right section.

### How to make an API call

`https://api.openweathermap.org/data/3.0/onecall/day_summary?lat={lat}&lon={lon}&date={date}&appid=[{API key}](https://home.openweathermap.org/api_keys)`

| Parameters |     |     |
| --- |     |     | --- | --- |
| `lat` | required | Latitude, decimal (-90; 90) |
| `lon` | required | Longitude, decimal (-180; 180) |
| `date` | required | Date in the \`YYYY-MM-DD\` format for which data is requested. Date is available for 46+ years archive (starting from 1979-01-02) up to the 1,5 years ahead forecast to the current date |
| `appid` | required | Your unique API key (you can always find it on your account page under the ["API key" tab](https://home.openweathermap.org/api_keys)) |
| `units` | optional | Units of measurement. `standard`, `metric` and `imperial` units are available. If you do not use the `units` parameter, `standard` units will be applied by default. [Learn more](#data) |
| `lang` | optional | You can use the `lang` parameter to get the output in your language. [Learn more](#multi) |

If the service detected timezone for your location incorrectly you can specify correct timezone manually by adding `tz` parameter in the ±XX:XX format to API call.

`https://api.openweathermap.org/data/3.0/onecall/day_summary?lat={lat}&lon={lon}&date={date}&tz={tz}&appid=[{API key}](https://home.openweathermap.org/api_keys)`

`https://api.openweathermap.org/data/3.0/onecall/day_summary?lat=60.45&lon=-38.67&date=2023-03-30&tz=+03:00&appid=[{API key}](https://home.openweathermap.org/api_keys)`

Please pay attention that in case timezone is specified time of afternoon, night, evening, morning temperatures, pressure, humidity will be returned in accordance with this specified timezone.

Before making an API call, please note, that One Call 3.0 is included in the "One Call by Call" subscription **only**. [Learn more](https://openweathermap.org/price)

`https://api.openweathermap.org/data/3.0/onecall/day_summary?lat=39.099724&lon=-94.578331&date=2020-03-04&appid=[{API key}](https://home.openweathermap.org/api_keys)`

                   `  {   "lat":33,   "lon":35,   "tz":"+02:00",   "date":"2020-03-04",   "units":"standard",   "cloud_cover":{      "afternoon":0   },   "humidity":{      "afternoon":33   },   "precipitation":{      "total":0   },   "temperature":{      "min":286.48,      "max":299.24,      "afternoon":296.15,      "night":289.56,      "evening":295.93,      "morning":287.59   },   "pressure":{      "afternoon":1015   },   "wind":{      "max":{         "speed":8.7,         "direction":120      }   }}`                
                 

- `lat` Latitude of the location, decimal (−90; 90)
- `lon` Longitude of the location, decimal (-180; 180)
- `tz` Timezone in the ±XX:XX format
- `date` Date specified in the API request in the \`YYYY-MM-DD\` format (from 1979-01-02 up to the 1,5 years ahead forecast)
- `units` Units of measurement specified in the request. [Learn more](#data)
- `cloud_cover` Cloud related information
    - `afternoon` Cloud cover at 12:00 for the date specified in the request, %
- `humidity` Humidity related information
    - `afternoon` Relative humidity at 12:00 for the date specified in the request, %
- `precipitation` Precipitation related information
    - `total` Total amount of liquid water equivalent of precipitation for the date specified in the request, mm
- `pressure` Atmospheric pressure related information
    - `afternoon` Atmospheric pressure at 12:00 for the date specified in the request, hPa
- `temperature` Temperature related information
    - `min` Minimum temperature for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `max` Maximum temperature for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `afternoon` Temperature at 12:00 for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `night` Temperature at 00:00 for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `evening` Temperature at 18:00 for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
    - `morning` Temperature at 06:00 for the date specified in the request. Units - default: kelvin, metric: Celsius, imperial: Fahrenheit. [How to change units used](#data)
- `wind` Wind speed related information
    - `max` Maximum wind speed related information
        - `speed` Maximum wind speed for the date specified in the request. Units – default: metre/sec, metric: metre/sec, imperial: miles/hour. [How to change units used](#data)
        - `direction` Wind cardinal direction relevant to the maximum wind speed, degrees (meteorological)

## Weather overview

This section describes how to get weather overview with a human-readable weather summary for today and tomorrow's forecast, utilizing OpenWeather AI technologies.

If you are interested in other functionality on One Call API 3.0, please check [Product concept](https://openweathermap.org/api/one-call-3#concept) to follow the right section.

### How to make an API call

`https://api.openweathermap.org/data/3.0/onecall/overview?lat={lat}&lon={lon}&appid=[{API key}](https://home.openweathermap.org/api_keys)`

| Parameters |     |     |
| --- |     |     | --- | --- |
| `lat` | required | Latitude, decimal (-90; 90) |
| `lon` | required | Longitude, decimal (-180; 180) |
| `appid` | required | Your unique API key (you can always find it on your account page under the ["API key" tab](https://home.openweathermap.org/api_keys)) |
| `date` | optional | The date the user wants to get a weather summary in the YYYY-MM-DD format. Data is available for today and tomorrow. If not specified, the current date will be used by default. Please note that the date is determined by the timezone relevant to the coordinates specified in the API request |
| `units` | optional | Units of measurement. Standard, metric and imperial units are available. If you do not use the units parameter, standard units will be applied by default. [Learn more](#data) |

`https://api.openweathermap.org/data/3.0/onecall/overview?lon=-11.8092&lat=51.509865&appid=[{API key}](https://home.openweathermap.org/api_keys)`

                   `{   "lat": 51.509865,   "lon": -0.118092,   "tz": "+01:00",   "date": "2024-05-13",   "units": "metric",   "weather_overview": "The current weather is overcast with a temperature of 16°C and a feels-like temperature of 16°C. The wind speed is 4 meter/sec with gusts up to 6 meter/sec coming from the west-southwest direction. The air pressure is at 1007 hPa with a humidity level of 79%. The dew point is at 12°C and the visibility is 10000 meters. The UV index is at 4, indicating moderate risk from the sun's UV rays. The sky is covered with overcast clouds, and there is no precipitation expected at the moment. Overall, it is a moderately cool and cloudy day with light to moderate winds from the west-southwest."}                                                 `          
                                       
                 

- `lat` Latitude of the location, decimal (−90; 90)
- `lon` Longitude of the location, decimal (-180; 180)
- `tz`Timezone in the ±XX:XX format
- `date` Date for which summary is generated in the format YYYY-MM-DD
- `units` Units of measurement specified in the request
- `weather_overview`AI generated weather overview for the requested date

## Other features

### List of weather condition codes

List of [weather condition codes](https://openweathermap.org/weather-conditions) with icons (range of thunderstorm, drizzle, rain, snow, clouds, atmosphere etc.)

### Units of measurement

`standard`, `metric` and `imperial` units are available.

[List of all API parameters with available units.](http://openweathermap.org/weather-data)

`https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&units={units}`

| Parameters |     |     |
| --- |     |     | --- | --- |
| `units` | optional | Units of measurement. `standard`, `metric` and `imperial` units are available. If you do not use the `units` parameter, `standard` units will be applied by default. |

Temperature is available in Fahrenheit, Celsius and Kelvin units.

Wind speed is available in miles/hour and meter/sec.

- For temperature in Fahrenheit and wind speed in miles/hour, use `units=imperial`
- For temperature in Celsius and wind speed in meter/sec, use `units=metric`
- Temperature in Kelvin and wind speed in meter/sec is used by default, so there is no need to use the units parameter in the API call if you want this

Standard (default)

`api.openweathermap.org/data/3.0/onecall?lat=30.489772&lon=-99.771335`

Metric

`api.openweathermap.org/data/3.0/onecall?lat=30.489772&lon=-99.771335&units=metric`

Imperial

`api.openweathermap.org/data/3.0/onecall?lat=30.489772&lon=-99.771335&units=imperial`

### Multilingual support

You can use `lang` parameter to get the output in your language.

The contents of the `description` field will be translated.

`https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&lang={lang}`

| Parameters |     |     |
| --- |     |     | --- | --- |
| `lang` | optional | You can use the `lang` parameter to get the output in your language. |

Before making an API call, please note, that One Call 3.0 is included in the "One Call by Call" subscription **only**. [Learn more](https://openweathermap.org/price)

`https://api.openweathermap.org/data/3.0/onecall?lat=30.489772&lon=-99.771335&lang=zh_cn`

We support the following languages. To select one, you can use the corresponding language code:

- `sq` Albanian
- `af` Afrikaans
- `ar` Arabic
- `az` Azerbaijani
- `eu` Basque
- `be` Belarusian
- `bg` Bulgarian
- `ca` Catalan
- `zh_cn` Chinese Simplified
- `zh_tw` Chinese Traditional
- `hr` Croatian
- `cz` Czech
- `da` Danish
- `nl` Dutch
- `en` English
- `fi` Finnish
- `fr` French
- `gl` Galician
- `de` German
- `el` Greek
- `he` Hebrew
- `hi` Hindi
- `hu` Hungarian
- `is` Icelandic
- `id` Indonesian
- `it` Italian
- `ja` Japanese
- `kr` Korean
- `ku` Kurmanji (Kurdish)
- `la` Latvian
- `lt` Lithuanian
- `mk` Macedonian
- `no` Norwegian
- `fa` Persian (Farsi)
- `pl` Polish
- `pt` Portuguese
- `pt_br` Português Brasil
- `ro` Romanian
- `ru` Russian
- `sr` Serbian
- `sk` Slovak
- `sl` Slovenian
- `sp, es` Spanish
- `sv, se` Swedish
- `th` Thai
- `tr` Turkish
- `ua, uk` Ukrainian
- `vi` Vietnamese
- `zu` Zulu

### List of national weather alerts sources

<div class="joplin-table-wrapper"><table><tbody><tr><th>Country</th><th>Agency</th></tr><tr></tr><tr><td>Albania</td><td>Institute of GeoSciences, Energy, Water and Environment of Albania</td></tr><tr><td>Algeria</td><td>National Meteorological Office</td></tr><tr><td>Argentina</td><td>National Weather Service of Argentina</td></tr><tr><td>Australia</td><td>Australian Bureau of Meteorology</td></tr><tr><td>Austria</td><td><ul><li>Central Institute for Meteorology and Geodynamics</li><li>Water Balance Department</li></ul></td></tr><tr><td>Bahrain</td><td>Bahrain Meteorological Directorate</td></tr><tr><td>Barbados</td><td>Barbados Meteorological Service</td></tr><tr><td>Belarus</td><td>State institution "Republican center for hydrometeorology, control of radioactive contamination and environmental monitoring" (Belhydromet)</td></tr><tr><td>Belgium</td><td>Royal Meteorological Institute</td></tr><tr><td>Belize</td><td>National Meteorological Service of Belize</td></tr><tr><td>Benin</td><td>National Meteorological Agency (METEO-BENIN)</td></tr><tr><td>Bosnia and Herzegovina</td><td><ul><li>Federal Hydrometeorological Institute of BiH</li><li>Republic Hydrometeorological Institute</li></ul></td></tr><tr><td>Botswana</td><td>Botswana Meteorological Services</td></tr><tr><td>Brazil</td><td>National Meteorological Institute - INMET</td></tr><tr><td>Bulgaria</td><td>National Institute of Meteorology and Hydrology - Plovdiv branch</td></tr><tr><td>Cameroon</td><td>Cameroon National Meteorological Service</td></tr><tr><td>Canada</td><td><ul><li>Alberta Emergency Management Agency (Government of Alberta, Ministry of Municipal Affairs)</li><li>Meteorological Service of Canada</li><li>Quebec Ministry of Public Safety</li><li>Yukon Emergency Measures Organization</li><li>Manitoba Emergency Management Organization</li></ul></td></tr><tr><td>Chile</td><td>Meteorological Directorate of Chile</td></tr><tr><td>Congo</td><td>National Civil Aviation Agency (ANAC Congo)</td></tr><tr><td>Costa Rica</td><td>National Meteorological Institute of Costa Rica</td></tr><tr><td>Croatia</td><td>State Hydrometeorological Institute (DHMZ)</td></tr><tr><td>Curacao and Sint Maarten</td><td>Meteorological Department Curacao</td></tr><tr><td>Cyprus</td><td>Republic of Cyprus - Department of Meteorology</td></tr><tr><td>Czech Republic</td><td>Czech Hydrometeorological Institute</td></tr><tr><td>Denmark</td><td>Danish Meteorological Institute</td></tr><tr><td>Ecuador</td><td>Ecuadoran Institute for Meteorology and Hydrology (INAMHI)</td></tr><tr><td>Egypt</td><td>Egyptian Meteorological Authority</td></tr><tr><td>Estonia</td><td>Estonian Environment Agency</td></tr><tr><td>Eswatini</td><td>Eswatini Meteorological Service</td></tr><tr><td>Finland</td><td>Finnish Meteorological Institute</td></tr><tr><td>France</td><td>Meteo-France</td></tr><tr><td>Gabon</td><td>General Directorate of Meteorology of Gabon</td></tr><tr><td>Germany</td><td>German Meteorological Office</td></tr><tr><td>Ghana</td><td>Ghana Meteorological Agency</td></tr><tr><td>Greece</td><td>Hellenic National Meteorological Service</td></tr><tr><td>Guinea</td><td>National Meteorological Agency of Guinea</td></tr><tr><td>Guyana</td><td>Hydrometeorological Service of Guyana</td></tr><tr><td>Hong Kong China</td><td>Hong Kong Observatory</td></tr><tr><td>Hungary</td><td>Hungarian Meteorological Service</td></tr><tr><td>Iceland</td><td>Icelandic Meteorological Office</td></tr><tr><td>India</td><td>India Meteorological Department</td></tr><tr><td>Indonesia</td><td><ul><li>Agency for Meteorology Climatology and Geophysics of Republic Indonesia (BMKG)</li><li>InaTEWS BMKG</li></ul></td></tr><tr><td>Ireland</td><td>Met Eireann - Irish Meteorological Service</td></tr><tr><td>Israel</td><td>Israel Meteorological Service</td></tr><tr><td>Italy</td><td>Italian Air Force National Meteorological Service</td></tr><tr><td>Ivory Coast</td><td>Airport, aeronautical and meteorological operating and development company (SODEXAM)</td></tr><tr><td>Jamaica</td><td>Meteorological Service of Jamaica</td></tr><tr><td>Japan</td><td>Japan Meteorological Business Support Center</td></tr><tr><td>Jordan</td><td>Jordanian Meteorological Department</td></tr><tr><td>Kazakhstan</td><td>National Hydrometeorological Service of the Republic of Kazakhstan (Kazhydromet)</td></tr><tr><td>Kenya</td><td>Kenya Meteorological Department</td></tr><tr><td>Kuwait</td><td>Kuwait Meteorological Department</td></tr><tr><td>Latvia</td><td>Latvian Environment, Geology and Meteorology Center</td></tr><tr><td>Lesotho</td><td>Lesotho Meteorological Services</td></tr><tr><td>Libya</td><td>Libyan National Meteorological Center</td></tr><tr><td>Lithuania</td><td>Lithuanian Hydrometeorological Service under the Ministry of Environment of the Republic of Lithuania (LHMS)</td></tr><tr><td>Luxembourg</td><td>Luxembourg Airport Administration</td></tr><tr><td>Macao China</td><td>Macao Meteorological and Geophysical Bureau</td></tr><tr><td>Madagascar</td><td>METEO Madagascar</td></tr><tr><td>Malawi</td><td>Malawi Department of Climate Change and Meteorological Services</td></tr><tr><td>Maldives</td><td>Maldives Meteorological Service</td></tr><tr><td>Mauritania</td><td>National Meteorological Office of Mauritania</td></tr><tr><td>Mauritius</td><td>Mauritius Meteorological Services</td></tr><tr><td>Mexico</td><td>CONAGUA - National Meteorological Service of Mexico</td></tr><tr><td>Moldova</td><td>State Hydrometeorological Service of Moldova</td></tr><tr><td>Mongolia</td><td>National Agency Meteorology and the Environmental Monitoring of Mongolia</td></tr><tr><td>Mozambique</td><td>National Institute of Meteorology of Mozambique</td></tr><tr><td>Myanmar</td><td>Myanmar Department of Meteorology and Hydrology</td></tr><tr><td>Netherlands</td><td>Royal Netherlands Meteorological Institute (KNMI)</td></tr><tr><td>New Zealand</td><td><ul><li>Meteorological Service of New Zealand Limited</li><li>National Emergency Management Agency</li><li>Fire and Emergency New Zealand</li><li>Civil Defence Emergency Management (CDEM) Groups</li></ul></td></tr><tr><td>New Zealand</td><td>New Zealand Emergency Mobile Alert</td></tr><tr><td>Niger</td><td>National Meteorological Directorate of Niger</td></tr><tr><td>Nigeria</td><td>Nigerian Meteorological Agency (NiMet)</td></tr><tr><td>North Macedonia</td><td>National Hydrometeorological Service - Republic of Macedonia</td></tr><tr><td>Norway</td><td><ul><li>Norwegian Meteorological Institute</li><li>Norwegian Water Resources and Energy Directorate</li></ul></td></tr><tr><td>Paraguay</td><td>Directorate of Meteorology and Hydrology</td></tr><tr><td>Philippines</td><td>Philippine Atmospheric Geophysical and Astronomical Services Administration</td></tr><tr><td>Poland</td><td>Institute of Meteorology and Water Management (IMGW-PIB)</td></tr><tr><td>Portugal</td><td>Portuguese Institute of Sea and Atmosphere, I.P.</td></tr><tr><td>Qatar</td><td>Qatar Meteorology Department</td></tr><tr><td>Republic of Korea</td><td>Korea Meteorological Administration, Weather Information</td></tr><tr><td>Romania</td><td>National Meteorological Administration</td></tr><tr><td>Russia-EN</td><td>Hydrometcenter of Russia</td></tr><tr><td>Russia-RU</td><td>Russian Federal Service for Hydrometeorology and Environmental Monitoring</td></tr><tr><td>Saudi Arabia</td><td>National Center for Meteorology - Kingdom of Saudi Arabia</td></tr><tr><td>Serbia</td><td>Republic Hydrometeorological Service of Serbia</td></tr><tr><td>Seychelles</td><td>Seychelles Meteorological Authority</td></tr><tr><td>Singapore</td><td>Meteorological Service Singapore</td></tr><tr><td>Slovakia</td><td>Slovak Hydrometeorological Institute</td></tr><tr><td>Slovenia</td><td>National Meteorological Service of Slovenia</td></tr><tr><td>Solomon Islands</td><td>Solomon Islands Meteorological Services</td></tr><tr><td>South Africa</td><td>South African Weather Service (SAWS)</td></tr><tr><td>Spain</td><td>State Meteorological Agency (AEMET)</td></tr><tr><td>Sudan</td><td>Sudan Meteorological Authority</td></tr><tr><td>Sweden</td><td>Swedish Meteorological and Hydrological Institute</td></tr><tr><td>Switzerland</td><td>MeteoSwiss</td></tr><tr><td>Tanzania</td><td>Tanzania Meteorological Authority</td></tr><tr><td>Thailand</td><td>Thai Meteorological Department</td></tr><tr><td>Timor-Leste</td><td>National Directorate of Meteorology and Geophysics of Timor-Leste</td></tr><tr><td>Trinidad and Tobago</td><td>Trinidad and Tobago Meteorological Service</td></tr><tr><td>Ukraine</td><td>Ukrainian Hydrometeorological Center</td></tr><tr><td>United Kingdom of Great Britain and Northern Ireland</td><td>UK Met Office</td></tr><tr><td>Uruguay</td><td>Uruguayan Institute of Meteorology</td></tr><tr><td>United States</td><td><ul><li>Environmental Protection Agency (EPA), Air Quality Alerts</li><li>Integrated Public Alerrt and Warning System (IPAWS)</li><li>National Oceanic and Atmospheric Administration (NOAA), National Tsunami Warning Center</li><li>National Oceanic and Atmospheric Administration (NOAA), National Weather Service</li><li>National Oceanic and Atmospheric Administration (NOAA), National Weather Service - Marine Zones</li><li>U.S. Geological Survey (USGS), Volcano Hazard Program</li></ul></td></tr><tr><td>USA</td><td>National Oceanic and Atmospheric Administration</td></tr><tr><td>Yemen</td><td>Yemeni Civil Aviation and Meteorology Authority (CAMA)</td></tr><tr><td>Zambia</td><td>Meteorological Department Zambia</td></tr><tr><td>Zimbabwe</td><td>Meteorological Services Department</td></tr></tbody></table></div>

Please note that some agencies from the list may cease to provide us the weather alert information.  
In case you don’t receive alerts from any agency, please [contact us](mailto:info@openweathermap.org).  
We constantly work on our product’s improvement and keep expanding the list of partner agencies.

### Call back function for JavaScript code

To use JavaScript code you can transfer `callback` functionName to JSONP callback.

`api.openweathermap.org/data/3.0/onecall?lat=38.8&lon=12.09&callback=test`

                           `test({  "lat": 40.12,  "lon": -96.66,  "timezone": "America/Chicago",  "timezone_offset": -18000,  "current": {    "dt": 1595243443,    "sunrise": 1595243663,    "sunset": 1595296278,    "temp": 293.28,    "feels_like": 293.82,    "pressure": 1016,    "humidity": 100,    "dew_point": 293.28,    "uvi": 10.64,    "clouds": 90,    "visibility": 10000,    "wind_speed": 4.6,    "wind_deg": 310,    "weather": [      {        "id": 501,        "main": "Rain",        "description": "moderate rain",        "icon": "10n"      },      {        "id": 201,        "main": "Thunderstorm",        "description": "thunderstorm with rain",        "icon": "11n"      }    ],    "rain": {      "1h": 2.93    }  },  "minutely": [    {      "dt": 1595243460,      "precipitation": 2.928    },    ...  },    "hourly": [    {      "dt": 1595242800,      "temp": 293.28,      "feels_like": 293.82,      "pressure": 1016,      "humidity": 100,      "dew_point": 293.28,      "clouds": 90,      "visibility": 10000,      "wind_speed": 4.6,      "wind_deg": 123,      "weather": [        {          "id": 501,          "main": "Rain",          "description": "moderate rain",          "icon": "10n"        }      ],      "pop": 0.99,      "rain": {        "1h": 2.46      }    },    ...  }"daily": [    {      "dt": 1595268000,      "sunrise": 1595243663,      "sunset": 1595296278,      "temp": {        "day": 298.82,        "min": 293.25,        "max": 301.9,        "night": 293.25,        "eve": 299.72,        "morn": 293.48      },      "feels_like": {        "day": 300.06,        "night": 292.46,        "eve": 300.87,        "morn": 293.75      },      "pressure": 1014,      "humidity": 82,      "dew_point": 295.52,      "wind_speed": 5.22,      "wind_deg": 146,      "weather": [        {          "id": 502,          "main": "Rain",          "description": "heavy intensity rain",          "icon": "10d"        }      ],      "clouds": 97,      "pop": 1,      "rain": 12.57,      "uvi": 10.64    },    ...    },"alerts": [    {      "sender_name": "NWS Tulsa (Eastern Oklahoma)",      "event": "Heat Advisory",      "start": 1597341600,      "end": 1597366800,      "description": "...HEAT ADVISORY REMAINS IN EFFECT FROM 1 PM THIS AFTERNOON TO\n8 PM CDT THIS EVENING...\n* WHAT...Heat index values of 105 to 109 degrees expected.\n* WHERE...Creek, Okfuskee, Okmulgee, McIntosh, Pittsburg,\nLatimer, Pushmataha, and Choctaw Counties.\n* WHEN...From 1 PM to 8 PM CDT Thursday.\n* IMPACTS...The combination of hot temperatures and high\nhumidity will combine to create a dangerous situation in which\nheat illnesses are possible."    },    ...  ]  })                           `
                           
                        

## API errors

### Structure of API errors

In case of incorrected API call you will receive API error response. Error response payload returned for all types of errors with the structure below.

`Example of error response`

                `{    "cod":400,    "message":"Invalid date format",    "parameters": [        "date"    ]}        `
        
              

- `cod` Code of error
- `message` Description of error
- `parameters`(optional) List of request parameters names that are related to this particular error

### Errors list

  
Please find more detailed information about some popular errors below.

API calls return an error 400

Error 400 - Bad Request. You can get 400 error if either some mandatory parameters in the request are missing or some of request parameters have incorrect format or values out of allowed range. List of all parameters names that are missing or incorrect will be returned in \`parameters\`attribute of the \`ErrorResponse\` object.

API calls return an error 401

Error 401 - Unauthorized. You can get 401 error if API token did not providen in the request or in case API token provided in the request does not grant access to this API. You must add API token with granted access to the product to the request before returning it.

API calls return an error 404

Error 404 - Not Found. You can get 404 error if data with requested parameters (`lat`, `lon`, `date` etc) does not exist in service database. You must not retry the same request.

API calls return an error 429

Error 429 - Too Many Requests. You can get 429 error if key quota of requests for provided API to this API was exceeded. You may retry request after some time or after extending your key quota.

API calls return errors '5xx'

Errors 5xx - Unexpected Error. You can get '5xx' error in case of other internal errors. Error Response code will be \`5xx\`. Please [contact us](https://home.openweathermap.org/questions) and enclose an example of your API request that receives this error into your email to let us analyze it and find a solution for you promptly. You may retry the request which led to this error.