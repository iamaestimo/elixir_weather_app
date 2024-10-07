defmodule WeatherAppWeb.WeatherLive do
  use WeatherAppWeb, :live_view
  alias WeatherApp.Weather

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", weather: nil, loading: false, error: nil)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:run_search, query})
    {:noreply, assign(socket, loading: true)}
  end

  def handle_info({:run_search, query}, socket) do
    case Weather.get_forecast(query) do
      {:ok, weather} ->
        {:noreply, assign(socket, weather: weather, loading: false, error: nil)}
      {:error, message} ->
        {:noreply, assign(socket, weather: nil, loading: false, error: message)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Weather Forecast</h1>
      <form phx-submit="search">
        <input type="text" name="query" value={@query} placeholder="Enter city or lat,lon" />
        <button type="submit">Search</button>
      </form>

      <%= if @loading do %>
        <p>Loading...</p>
      <% end %>

      <%= if @error do %>
        <p class="error"><%= @error %></p>
      <% end %>

      <%= if @weather do %>
        <h2><%= @weather.location %></h2>
        <p>Current: <%= @weather.current.temp_c %>°C, <%= @weather.current.condition %></p>

        <h3>3-Day Forecast:</h3>
        <ul>
          <%= for day <- @weather.forecast do %>
            <li>
              <%= day.date %>: <%= day.min_temp_c %>°C to <%= day.max_temp_c %>°C, <%= day.condition %>
            </li>
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end
end
