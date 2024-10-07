defmodule WeatherApp.WeatherTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "get_forecast/1 returns parsed forecast data" do
    expect(WeatherApp.MockApiClient, :call, fn %{method: :get, url: url}, _opts ->
      assert String.contains?(url, "forecast.json")
      {:ok, %Tesla.Env{status: 200, body: sample_api_response()}}
    end)

    assert {:ok, forecast} = WeatherApp.Weather.get_forecast("London")
    assert forecast.location == "London"
    assert forecast.current.temp_c == 15.0
    assert length(forecast.forecast) == 3
  end

  test "get_forecast/1 handles API errors" do
    expect(WeatherApp.MockApiClient, :call, fn %{method: :get, url: url}, _opts ->
      assert String.contains?(url, "forecast.json")
      {:ok, %Tesla.Env{status: 400, body: %{"error" => %{"message" => "Invalid request"}}}}
    end)

    assert {:error, "API error: 400 - Invalid request"} = WeatherApp.Weather.get_forecast("Invalid")
  end

  defp sample_api_response do
    %{
      "location" => %{"name" => "London"},
      "current" => %{
        "temp_c" => 15.0,
        "condition" => %{"text" => "Partly cloudy"}
      },
      "forecast" => %{
        "forecastday" => [
          %{
            "date" => "2023-05-01",
            "day" => %{
              "maxtemp_c" => 20.0,
              "mintemp_c" => 10.0,
              "condition" => %{"text" => "Sunny"}
            }
          },
          %{
            "date" => "2023-05-02",
            "day" => %{
              "maxtemp_c" => 22.0,
              "mintemp_c" => 12.0,
              "condition" => %{"text" => "Partly cloudy"}
            }
          },
          %{
            "date" => "2023-05-03",
            "day" => %{
              "maxtemp_c" => 18.0,
              "mintemp_c" => 9.0,
              "condition" => %{"text" => "Light rain"}
            }
          }
        ]
      }
    }
  end
end
