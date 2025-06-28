#!/usr/bin/env node

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');

class OpenMeteoMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'open-meteo-weather',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'get_weather_forecast',
            description: 'Get comprehensive weather data from Open-Meteo API with experienced weatherman analysis for any location',
            inputSchema: {
              type: 'object',
              properties: {
                latitude: {
                  type: 'number',
                  description: 'Latitude coordinate',
                  default: 42.742830
                },
                longitude: {
                  type: 'number',
                  description: 'Longitude coordinate',
                  default: -73.801163
                },
                location_name: {
                  type: 'string',
                  description: 'Location name for context',
                  default: 'Albany, NY'
                },
                past_days: {
                  type: 'integer',
                  description: 'Past days to include (0-92)',
                  default: 2,
                  minimum: 0,
                  maximum: 92
                },
                forecast_days: {
                  type: 'integer',
                  description: 'Forecast days to include (1-16)',
                  default: 3,
                  minimum: 1,
                  maximum: 16
                },
                timezone: {
                  type: 'string',
                  description: 'Timezone for the location',
                  default: 'America/New_York'
                }
              }
            }
          }
        ]
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      if (name === 'get_weather_forecast') {
        return await this.getWeatherForecast(args);
      }

      throw new Error(`Unknown tool: ${name}`);
    });
  }

  async getWeatherForecast(args = {}) {
    const {
      latitude = 42.742830,
      longitude = -73.801163,
      location_name = 'Albany, NY',
      past_days = 2,
      forecast_days = 3,
      timezone = 'America/New_York'
    } = args;

    try {
      console.error(`🌤️  Fetching weather for ${location_name} (${latitude}, ${longitude})`);
      
      // Build the Open-Meteo API URL (exactly like your bash function)
      const baseUrl = 'https://api.open-meteo.com/v1/forecast';
      const params = new URLSearchParams({
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        current: 'temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,weather_code,cloud_cover,visibility',
        hourly: 'temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation,precipitation_probability,rain,showers,snowfall,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,visibility,cape',
        daily: 'weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant',
        past_days: past_days.toString(),
        forecast_days: forecast_days.toString(),
        timezone: timezone
      });

      const apiUrl = `${baseUrl}?${params}`;
      console.error(`📡 API URL: ${apiUrl.substring(0, 150)}...`);

      const response = await fetch(apiUrl);
      
      if (!response.ok) {
        throw new Error(`Open-Meteo API error: ${response.status} ${response.statusText}`);
      }

      const weatherData = await response.json();
      console.error(`✅ API call successful, got ${JSON.stringify(weatherData).length} bytes`);
      
      // Get current date in the specified timezone
      const currentDate = new Date().toLocaleString('en-US', { 
        timeZone: timezone,
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZoneName: 'short'
      });

      // Create the weatherman analysis prompt (matching your bash function)
      const weathermanPrompt = `You are a very experienced and cool Weatherman with an aged style and grace. You have vast knowledge and experience providing weather insights from patterns in the data that some weathermen might miss. You specialize in predicting hazardous conditions for the ${location_name} area, either current or near future.

The current date is: ${currentDate}

Please analyze this comprehensive weather data and provide your expert assessment in three sections:

1. **DETAILED CURRENT CONDITIONS** 
   - Include temperature, dew point, humidity, visibility, pressure trends
   - Note any immediate weather patterns or concerns

2. **FUTURE FORECAST** 
   - ${forecast_days}-day outlook with your experienced pattern analysis
   - Highlight any significant weather changes or trends
   - Include dates for all forecasts as provided in the data

3. **ALERTS & NOTABLE CONDITIONS**
   - Any hazardous weather conditions (current or approaching)
   - Unusual patterns that might be missed by less experienced forecasters  
   - Recommendations for the ${location_name} area

Please indicate the current date as given and indicate the date of the forecast as provided in the json weather information. I want you to be working with only the most up-to-date information and to be aware when you are not. Work only with the most up-to-date information provided and indicate dates of forecasts as provided in the JSON.

Weather Data:
${JSON.stringify(weatherData, null, 2)}`;

      return {
        content: [
          {
            type: 'text',
            text: `# Weather Report for ${location_name}

**Location**: ${location_name} (${latitude}, ${longitude})
**Report Generated**: ${currentDate}
**Data Source**: Open-Meteo API

## Analysis Instructions for AI
${weathermanPrompt}

---

**Technical Details:**
- API Response Status: Success
- Timezone: ${timezone}
- Past Days: ${past_days}
- Forecast Days: ${forecast_days}
- Data Timestamp: ${weatherData.current?.time || 'Not provided'}

The weather data is comprehensive and ready for experienced weatherman analysis.`
          }
        ]
      };

    } catch (error) {
      console.error(`❌ Weather API Error: ${error.message}`);
      return {
        content: [
          {
            type: 'text',
            text: `# Weather Service Error

**Location**: ${location_name}
**Error**: Failed to retrieve weather data

**Details**: ${error.message}

Please check the coordinates and try again. The Open-Meteo API may be temporarily unavailable.`
          }
        ],
        isError: true
      };
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('🚀 Open-Meteo MCP server running on stdio');
  }
}

// Start the server
const server = new OpenMeteoMCPServer();
server.run().catch((error) => {
  console.error('❌ Failed to start MCP server:', error);
  process.exit(1);
});
