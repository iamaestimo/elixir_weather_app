defmodule WeatherApp.MockApiClient do
  use Tesla

  plug Tesla.Middleware.Telemetry
  plug Tesla.Middleware.JSON

  def get_forecast(api_key, query) do
    IO.puts("MockApiClient: get_forecast called with query: #{query}")
    case query do
      "slow" -> simulate_slow_request()
      "error" -> simulate_api_error()
      "timeout" -> simulate_timeout()
      _ -> simulate_success()
    end
  end

  defp simulate_slow_request do
    IO.puts("MockApiClient: Simulating slow request")
    Process.sleep(5000)  # Simulate a 5-second delay
    simulate_success()
  end

  defp simulate_api_error do
    IO.puts("MockApiClient: Simulating API error")
    {:ok, %Tesla.Env{status: 400, body: %{"error" => %{"message" => "Invalid request"}}}}
  end

  defp simulate_timeout do
    IO.puts("MockApiClient: Simulating timeout")
    {:error, :timeout}
  end

  defp simulate_success do
    IO.puts("MockApiClient: Simulating successful request")
    {:ok, %Tesla.Env{
      status: 200,
      body: %{
        "location" => %{"name" => "Mock City"},
        "current" => %{
          "temp_c" => 20.5,
          "condition" => %{"text" => "Sunny"}
        },
        "forecast" => %{
          "forecastday" => [
            %{
              "date" => Date.utc_today() |> Date.to_string(),
              "day" => %{
                "maxtemp_c" => 25.3,
                "mintemp_c" => 15.7,
                "condition" => %{"text" => "Partly cloudy"}
              }
            }
          ]
        }
      }
    }}
  end
end
