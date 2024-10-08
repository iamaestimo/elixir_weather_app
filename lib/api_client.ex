defmodule WeatherApp.ApiClient do
  use Tesla

  plug Tesla.Middleware.Telemetry
  plug Tesla.Middleware.BaseUrl, "http://api.weatherapi.com/v1"
  plug Tesla.Middleware.JSON

  def get_forecast(api_key, query) do
    get("/forecast.json", query: [key: api_key, q: query, days: 3])
  end
end
