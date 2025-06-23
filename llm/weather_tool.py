import subprocess


def get_weather_forecast():
    """Get comprehensive weather forecast with full historical context and all available meteorological data for Albany NY area."""
    try:
        result = subprocess.run(['./weather2.sh'],
                                capture_output=True,
                                text=True,
                                check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error getting weather data: {e.stderr}"
    except FileNotFoundError:
        return "Error: weather2.sh not found or not executable"
