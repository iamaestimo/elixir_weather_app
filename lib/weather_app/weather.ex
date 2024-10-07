defmodule WeatherApp.Weather do
  alias WeatherApp.ApiClient

  def get_forecast(query) do
    api_key = Application.get_env(:weather_app, :api_key)

    case ApiClient.get_forecast(api_key, query) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, parse_forecast(body)}
      {:ok, %{status: status, body: body}} ->
        {:error, "API error: #{status} - #{body["error"]["message"]}"}
      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp parse_forecast(body) do
    %{
      location: body["location"]["name"],
      current: %{
        temp_c: body["current"]["temp_c"],
        condition: body["current"]["condition"]["text"]
      },
      forecast: Enum.map(body["forecast"]["forecastday"], fn day ->
        %{
          date: day["date"],
          max_temp_c: day["day"]["maxtemp_c"],
          min_temp_c: day["day"]["mintemp_c"],
          condition: day["day"]["condition"]["text"]
        }
      end)
    }
  end
end
