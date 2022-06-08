require 'sinatra'
require 'dotenv/load'
require 'open-weather-ruby-client'
require 'pry'
require 'httparty'

configure do
  enable :sessions
  # set :session_secret, 'secret'????
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
end

=begin
TODO:
- CSS -- style the thing!
=end

CLIENT = OpenWeather::Client.new(
  api_key: ENV['OPEN_WEATHER_API_KEY']
)

get "/" do
  if session[:city] #if a value is assigned
    @city = session[:city].split.map(&:capitalize).join(' ')
    @country = session[:country].split.map(&:capitalize).join(' ')
    weather = get_weather(@city, @country)

    @lat = weather["coord"]["lat"]
    @lon = weather["coord"]["lon"]
    @current_weather = weather["main"]

    weekly_forecast_data = weekly_forecast(@lat, @lon)

    @forecast_data = forecast_hashes(weekly_forecast_data)

    @date = "#{Time.now.month}-#{Time.now.day}-#{Time.now.year}"
  end
  erb :home
end

post "/city_country_input" do
  if get_weather(params[:city], params[:country]) ==  "error"
    session[:error] = "That is not a valid city or country"
  else
    session[:city] = params[:city]
    session[:country] = params[:country]
  end
  redirect "/"
end

post "/reset" do
  session.delete(:city)
  session.delete(:country)
  redirect "/"
end

def get_weather(city, country, units = "imperial")
  begin
    data = CLIENT.current_weather(
      city: city,
      country: country,
      units: units
      )
  rescue NoMethodError, Faraday::ResourceNotFound
    "error"
  end
end

def weekly_forecast(lattitude, longitude)
  data = CLIENT.one_call(lat: lattitude, lon: longitude, exclude: ['minutely', 'hourly'], units: "imperial")
end

def forecast_hashes(data)
  data["daily"].map do |hsh, idx|
    {
      day: hsh["dt"].to_s,
      day_temp: hsh["temp"]["day"],
      night_temp: hsh["temp"]["night"],
      feels_like_day: hsh["feels_like"]["day"],
      feels_like_night: hsh["feels_like"]["night"],
      uvi: hsh["uvi"]
    }
  end
end


# {"coord"=>{"lon"=>-117.1573, "lat"=>32.7153},
#  "weather"=>
#   [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/04d@2x.png>,
#     "icon"=>"04d",
#     "id"=>804,
#     "main"=>"Clouds",
#     "description"=>"overcast clouds"}],
#  "base"=>"stations",
#  "main"=>
#   {"temp"=>68.88,
#    "feels_like"=>69.46,
#    "temp_min"=>62.74,
#    "temp_max"=>81.39,
#    "pressure"=>1011,
#    "humidity"=>85},
#  "visibility"=>10000,
#  "wind"=>{"speed"=>10.36, "deg"=>250},
#  "clouds"=>{"all"=>100},
#  "dt"=>2022-06-07 17:03:15 UTC,
#  "sys"=>
#   {"type"=>2,
#    "id"=>2005032,
#    "country"=>"US",
#    "sunrise"=>2022-06-07 12:40:36 UTC,
#    "sunset"=>2022-06-08 02:54:43 UTC},
#  "timezone"=>-25200,
#  "id"=>5391811,
#  "name"=>"San Diego",
#  "cod"=>200}


# response = HTTParty.get("http://api.openweathermap.org/geo/1.0/direct?q=Los Angeles,USA&appid=ENV['OPEN_WEATHER_API_KEY']")




# "daily"=>
# [{"dt"=>2022-06-07 09:00:00 UTC,
#   "sunrise"=>2022-06-07 02:34:25 UTC,
#   "sunset"=>2022-06-07 16:45:06 UTC,
#   "temp"=>{"day"=>79.07, "min"=>71.74, "max"=>80.06, "night"=>76.69, "eve"=>78.19, "morn"=>71.74},
#   "feels_like"=>{"day"=>79.07, "night"=>77.4, "eve"=>78.8, "morn"=>72.46},
#   "pressure"=>1009,
#   "humidity"=>66,
#   "dew_point"=>66.22,
#   "wind_speed"=>12.15,
#   "wind_deg"=>255,
#   "wind_gust"=>11.07,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>3,
#   "uvi"=>10.06},

#  {"dt"=>2022-06-08 09:00:00 UTC,
#   "sunrise"=>2022-06-08 02:34:18 UTC,
#   "sunset"=>2022-06-08 16:45:34 UTC,
#   "temp"=>{"day"=>80.92, "min"=>72.54, "max"=>81.39, "night"=>74.52, "eve"=>79.23, "morn"=>72.54},
#   "feels_like"=>{"day"=>83.1, "night"=>74.71, "eve"=>79.23, "morn"=>73.15},
#   "pressure"=>1010,
#   "humidity"=>61,
#   "dew_point"=>65.07,
#   "wind_speed"=>12.73,
#   "wind_deg"=>267,
#   "wind_gust"=>12.86,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>3,
#   "uvi"=>10.35},

#  {"dt"=>2022-06-09 09:00:00 UTC,
#   "sunrise"=>2022-06-09 02:34:13 UTC,
#   "sunset"=>2022-06-09 16:46:02 UTC,
#   "temp"=>{"day"=>83.61, "min"=>72.91, "max"=>84.22, "night"=>77.83, "eve"=>82.17, "morn"=>73.4},
#   "feels_like"=>{"day"=>83.21, "night"=>78.04, "eve"=>83.43, "morn"=>73.08},
#   "pressure"=>1010,
#   "humidity"=>42,
#   "dew_point"=>56.86,
#   "wind_speed"=>12.1,
#   "wind_deg"=>354,
#   "wind_gust"=>12.82,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>0,
#   "uvi"=>10.65},

#  {"dt"=>2022-06-10 09:00:00 UTC,
#   "sunrise"=>2022-06-10 02:34:09 UTC,
#   "sunset"=>2022-06-10 16:46:28 UTC,
#   "temp"=>{"day"=>84.06, "min"=>74.7, "max"=>84.42, "night"=>77.38, "eve"=>81.63, "morn"=>74.79},
#   "feels_like"=>{"day"=>84.4, "night"=>77.77, "eve"=>82.65, "morn"=>74.84},
#   "pressure"=>1011,
#   "humidity"=>46,
#   "dew_point"=>59.32,
#   "wind_speed"=>13.78,
#   "wind_deg"=>338,
#   "wind_gust"=>14.79,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>0,
#   "uvi"=>10.73},

#  {"dt"=>2022-06-11 09:00:00 UTC,
#   "sunrise"=>2022-06-11 02:34:06 UTC,
#   "sunset"=>2022-06-11 16:46:53 UTC,
#   "temp"=>{"day"=>85.44, "min"=>73.53, "max"=>86.13, "night"=>79.52, "eve"=>83.28, "morn"=>73.53},
#   "feels_like"=>{"day"=>84.43, "night"=>79.52, "eve"=>83.88, "morn"=>73.54},
#   "pressure"=>1011,
#   "humidity"=>38,
#   "dew_point"=>54.82,
#   "wind_speed"=>11.39,
#   "wind_deg"=>333,
#   "wind_gust"=>13.31,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>0,
#   "uvi"=>10.87},

#  {"dt"=>2022-06-12 09:00:00 UTC,
#   "sunrise"=>2022-06-12 02:34:05 UTC,
#   "sunset"=>2022-06-12 16:47:18 UTC,
#   "temp"=>{"day"=>83.21, "min"=>75.42, "max"=>83.21, "night"=>75.42, "eve"=>77.74, "morn"=>76.51},
#   "feels_like"=>{"day"=>84.94, "night"=>76.14, "eve"=>78.46, "morn"=>76.96},
#   "pressure"=>1007,
#   "humidity"=>54,
#   "dew_point"=>63.36,
#   "wind_speed"=>14.56,
#   "wind_deg"=>290,
#   "wind_gust"=>14.56,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/01d@2x.png>,
#      "icon"=>"01d",
#      "id"=>800,
#      "main"=>"Clear",
#      "description"=>"clear sky"}],
#   "clouds"=>0,
#   "uvi"=>10.63},

#  {"dt"=>2022-06-13 09:00:00 UTC,
#   "sunrise"=>2022-06-13 02:34:06 UTC,
#   "sunset"=>2022-06-13 16:47:41 UTC,
#   "temp"=>{"day"=>77.34, "min"=>73.56, "max"=>79.05, "night"=>74.98, "eve"=>77.67, "morn"=>73.56},
#   "feels_like"=>{"day"=>77.83, "night"=>75.67, "eve"=>78.19, "morn"=>74.14},
#   "pressure"=>1008,
#   "humidity"=>65,
#   "dew_point"=>64.49,
#   "wind_speed"=>14.12,
#   "wind_deg"=>247,
#   "wind_gust"=>15.35,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/10d@2x.png>,
#      "icon"=>"10d",
#      "id"=>500,
#      "main"=>"Rain",
#      "description"=>"light rain"}],
#   "clouds"=>100,
#   "rain"=>0.59,
#   "uvi"=>11},

#  {"dt"=>2022-06-14 09:00:00 UTC,
#   "sunrise"=>2022-06-14 02:34:08 UTC,
#   "sunset"=>2022-06-14 16:48:03 UTC,
#   "temp"=>{"day"=>78.69, "min"=>73.53, "max"=>80.15, "night"=>75.56, "eve"=>78.22, "morn"=>73.99},
#   "feels_like"=>{"day"=>79.36, "night"=>76.39, "eve"=>78.85, "morn"=>74.77},
#   "pressure"=>1009,
#   "humidity"=>66,
#   "dew_point"=>65.95,
#   "wind_speed"=>12.48,
#   "wind_deg"=>274,
#   "wind_gust"=>12.53,
#   "weather"=>
#    [{"icon_uri"=>#<URI::HTTP http://openweathermap.org/img/wn/10d@2x.png>,
#      "icon"=>"10d",
#      "id"=>500,
#      "main"=>"Rain",
#      "description"=>"light rain"}],
#   "clouds"=>85,
#   "rain"=>0.57,
#   "uvi"=>11}]
