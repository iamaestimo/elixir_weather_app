defmodule WeatherAppWeb.WeatherLive do
  use WeatherAppWeb, :live_view
  alias WeatherApp.Weather

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", weather: nil, loading: false, error: nil, temp_unit: :celsius, search_history: [], show_history: false)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:run_search, query})
    {:noreply, assign(socket, query: query, loading: true, show_history: false)}
  end

  def handle_event("toggle_temp_unit", _, socket) do
    new_unit = if socket.assigns.temp_unit == :celsius, do: :fahrenheit, else: :celsius
    {:noreply, assign(socket, temp_unit: new_unit)}
  end

  def handle_event("show_history", _, socket) do
    {:noreply, assign(socket, show_history: true)}
  end

  def handle_event("hide_history", _, socket) do
    {:noreply, assign(socket, show_history: false)}
  end

  def handle_event("select_history", %{"query" => query}, socket) do
    send(self(), {:run_search, query})
    {:noreply, assign(socket, query: query, loading: true, show_history: false)}
  end

  def handle_info({:run_search, query}, socket) do
    case Weather.get_forecast(query) do
      {:ok, weather} ->
        updated_history = update_search_history(socket.assigns.search_history, query)
        {:noreply, assign(socket, weather: weather, loading: false, error: nil, search_history: updated_history)}
      {:error, message} ->
        {:noreply, assign(socket, weather: nil, loading: false, error: message)}
    end
  end

  defp update_search_history(history, query) do
    history
    |> Enum.reject(&(&1 == query))
    |> Enum.take(4)
    |> then(&[query | &1])
  end

  def weather_icon(condition) do
    case String.downcase(condition) do
      "sunny" -> "wi-day-sunny"
      "clear" -> "wi-day-sunny"
      "partly cloudy" -> "wi-day-cloudy"
      "cloudy" -> "wi-cloudy"
      "overcast" -> "wi-cloudy"
      "mist" -> "wi-fog"
      "patchy rain possible" -> "wi-day-rain-mix"
      "patchy snow possible" -> "wi-day-snow"
      "patchy sleet possible" -> "wi-day-sleet"
      "patchy freezing drizzle possible" -> "wi-day-sleet"
      "thundery outbreaks possible" -> "wi-day-thunderstorm"
      "blowing snow" -> "wi-snow-wind"
      "blizzard" -> "wi-snow-wind"
      "fog" -> "wi-fog"
      "freezing fog" -> "wi-fog"
      "patchy light drizzle" -> "wi-day-sprinkle"
      "light drizzle" -> "wi-day-sprinkle"
      "freezing drizzle" -> "wi-day-rain-mix"
      "heavy freezing drizzle" -> "wi-day-rain-mix"
      "patchy light rain" -> "wi-day-rain-mix"
      "light rain" -> "wi-day-rain-mix"
      "moderate rain at times" -> "wi-day-rain"
      "moderate rain" -> "wi-rain"
      "heavy rain at times" -> "wi-day-rain"
      "heavy rain" -> "wi-rain"
      "light freezing rain" -> "wi-day-sleet"
      "moderate or heavy freezing rain" -> "wi-day-sleet"
      "light sleet" -> "wi-day-sleet"
      "moderate or heavy sleet" -> "wi-day-sleet"
      "patchy light snow" -> "wi-day-snow"
      "light snow" -> "wi-day-snow"
      "patchy moderate snow" -> "wi-day-snow"
      "moderate snow" -> "wi-snow"
      "patchy heavy snow" -> "wi-day-snow"
      "heavy snow" -> "wi-snow"
      "ice pellets" -> "wi-hail"
      "light rain shower" -> "wi-day-showers"
      "moderate or heavy rain shower" -> "wi-day-showers"
      "torrential rain shower" -> "wi-day-showers"
      "light sleet showers" -> "wi-day-sleet"
      "moderate or heavy sleet showers" -> "wi-day-sleet"
      "light snow showers" -> "wi-day-snow"
      "moderate or heavy snow showers" -> "wi-snow"
      "light showers of ice pellets" -> "wi-day-hail"
      "moderate or heavy showers of ice pellets" -> "wi-day-hail"
      "patchy light rain with thunder" -> "wi-day-storm-showers"
      "moderate or heavy rain with thunder" -> "wi-thunderstorm"
      "patchy light snow with thunder" -> "wi-day-snow-thunderstorm"
      "moderate or heavy snow with thunder" -> "wi-snow-thunderstorm"
      _ -> "wi-day-sunny"  # default icon
    end
  end

  def celsius_to_fahrenheit(celsius) do
    (celsius * 9/5) + 32
  end

  def format_temp(temp, :celsius), do: "#{Float.round(temp, 1)}°C"
  def format_temp(temp, :fahrenheit), do: "#{Float.round(celsius_to_fahrenheit(temp), 1)}°F"

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8 text-center text-blue-600">Weather Forecast</h1>

      <div class="mb-8 relative">
        <form phx-submit="search" class="flex items-center justify-center">
          <div class="relative flex-grow">
            <input type="text" name="query" value={@query} placeholder="Enter city or lat,lon"
                   class="w-full px-4 py-2 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                   phx-focus="show_history" phx-blur="hide_history" autocomplete="off" />
            <%= if @show_history and length(@search_history) > 0 do %>
              <div class="absolute z-10 w-full bg-white border border-gray-300 rounded-b-lg shadow-lg">
                <%= for item <- @search_history do %>
                  <div class="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                       phx-click="select_history" phx-value-query={item}>
                    <%= item %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-r-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500">
            Search
          </button>
        </form>
      </div>

      <div class="flex justify-center mb-4">
        <button phx-click="toggle_temp_unit" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500">
          Toggle °C/°F
        </button>
      </div>

      <%= if @loading do %>
        <div class="flex justify-center items-center">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      <% end %>

      <%= if @error do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
          <strong class="font-bold">Error:</strong>
          <span class="block sm:inline"><%= @error %></span>
        </div>
      <% end %>

      <%= if @weather do %>
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
          <div class="px-6 py-4">
            <h2 class="text-2xl font-bold text-gray-800 mb-2"><%= @weather.location %></h2>
            <div class="flex items-center">
              <i class={"wi #{weather_icon(@weather.current.condition)} text-5xl mr-4"}></i>
              <p class="text-gray-600 text-lg">
                <%= format_temp(@weather.current.temp_c, @temp_unit) %>, <%= @weather.current.condition %>
              </p>
            </div>
          </div>
        </div>

        <h3 class="text-xl font-semibold mt-8 mb-4 text-gray-700">3-Day Forecast:</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <%= for day <- @weather.forecast do %>
            <div class="bg-white shadow-md rounded-lg overflow-hidden">
              <div class="px-4 py-3 bg-gray-100 border-b">
                <h4 class="font-semibold text-gray-800"><%= day.date %></h4>
              </div>
              <div class="px-4 py-3">
                <div class="flex items-center mb-2">
                  <i class={"wi #{weather_icon(day.condition)} text-3xl mr-2"}></i>
                  <p class="text-sm text-gray-600"><%= day.condition %></p>
                </div>
                <p class="text-sm text-gray-600">
                  <%= format_temp(day.min_temp_c, @temp_unit) %> to <%= format_temp(day.max_temp_c, @temp_unit) %>
                </p>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
