# defmodule WeatherAppWeb.WeatherLive do
#   use WeatherAppWeb, :live_view
#   alias WeatherApp.Weather

#   def mount(_params, _session, socket) do
#     {:ok, assign(socket, query: "", weather: nil, loading: false, error: nil)}
#   end

#   def handle_event("search", %{"query" => query}, socket) do
#     send(self(), {:run_search, query})
#     {:noreply, assign(socket, loading: true)}
#   end

#   def handle_info({:run_search, query}, socket) do
#     case Weather.get_forecast(query) do
#       {:ok, weather} ->
#         {:noreply, assign(socket, weather: weather, loading: false, error: nil)}
#       {:error, message} ->
#         {:noreply, assign(socket, weather: nil, loading: false, error: message)}
#     end
#   end

#   def render(assigns) do
#     ~H"""
#     <div>
#       <h1>Weather Forecast</h1>
#       <form phx-submit="search">
#         <input type="text" name="query" value={@query} placeholder="Enter city or lat,lon" />
#         <button type="submit">Search</button>
#       </form>

#       <%= if @loading do %>
#         <p>Loading...</p>
#       <% end %>

#       <%= if @error do %>
#         <p class="error"><%= @error %></p>
#       <% end %>

#       <%= if @weather do %>
#         <h2><%= @weather.location %></h2>
#         <p>Current: <%= @weather.current.temp_c %>°C, <%= @weather.current.condition %></p>

#         <h3>3-Day Forecast:</h3>
#         <ul>
#           <%= for day <- @weather.forecast do %>
#             <li>
#               <%= day.date %>: <%= day.min_temp_c %>°C to <%= day.max_temp_c %>°C, <%= day.condition %>
#             </li>
#           <% end %>
#         </ul>
#       <% end %>
#     </div>
#     """
#   end
# end


defmodule WeatherAppWeb.WeatherLive do
  use WeatherAppWeb, :live_view
  alias WeatherApp.Weather

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", weather: nil, loading: false, error: nil)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:run_search, query})
    {:noreply, assign(socket, query: query, loading: true)}
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
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8 text-center text-blue-600">Weather Forecast</h1>

      <form phx-submit="search" class="mb-8">
        <div class="flex items-center justify-center">
          <input type="text" name="query" value={@query} placeholder="Enter city or lat,lon"
                 class="px-4 py-2 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-blue-500 flex-grow" />
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-r-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500">
            Search
          </button>
        </div>
      </form>

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
            <p class="text-gray-600 text-lg">
              Current: <%= @weather.current.temp_c %>°C, <%= @weather.current.condition %>
            </p>
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
                <p class="text-sm text-gray-600">
                  <%= day.min_temp_c %>°C to <%= day.max_temp_c %>°C
                </p>
                <p class="text-sm text-gray-600 mt-1">
                  <%= day.condition %>
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
