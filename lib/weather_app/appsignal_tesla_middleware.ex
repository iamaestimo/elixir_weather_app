defmodule WeatherApp.AppSignalTeslaMiddleware do
  def call(env, next, _options) do
    AppSignal.instrument("tesla.request", fn ->
      {duration, result} = :timer.tc(fn -> Tesla.run(env, next) end)

      case result do
        {:ok, env} ->
          AppSignal.add_distribution_value("tesla.request.duration", duration / 1000)
          AppSignal.set_sample_data("tesla.request", %{
            method: env.method,
            url: env.url,
            status: env.status,
            headers: env.headers
          })
          {:ok, env}

        {:error, reason} ->
          AppSignal.set_error("Tesla Error", "Request failed", %{
            reason: reason,
            method: env.method,
            url: env.url
          })
          {:error, reason}
      end
    end)
  end
end
