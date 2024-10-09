defmodule WeatherApp.Weather do
  alias WeatherApp.ApiClient

  @api_client Application.compile_env(:weather_app, :api_client, WeatherApp.ApiClient)

  def get_forecast(query) do
    IO.puts("Weather.get_forecast called with query: #{query}")
    IO.puts("Using API client: #{inspect(@api_client)}")

    AppSignal.set_sample_data("custom_data", %{query: query})

    AppSignal.instrument("Weather.get_forecast", fn ->
      api_key = Application.get_env(:weather_app, :api_key)

      case @api_client.get_forecast(api_key, query) do
        {:ok, %{status: 200, body: body}} ->
          IO.puts("Successful API response received")
          {:ok, parse_forecast(body)}
        {:ok, %{status: status, body: body}} ->
          IO.puts("API error received: status #{status}")
          {:error, "API error: #{status} - #{body["error"]["message"]}"}
        {:error, :timeout} ->
          IO.puts("API request timed out")
          {:error, "Request timed out"}
        {:error, error} ->
          IO.puts("API request failed: #{inspect(error)}")
          {:error, "Request failed: #{inspect(error)}"}
      end
    end)
  end

  defp parse_forecast(body) do
    # ... (keep the existing parse_forecast function)
  end
end
