This app is a basic weather check service. Input a city/country combination and get the current weather and a seven day forecast. This is my first time working with an API!

Inspired by Ryan Kulp over at FounderHacker.com. Thanks Ryan.

In this project, I learned how to:
- Work with API's using open-weather-ruby-client - https://github.com/founderhacker/open-weather-ruby-client#current-weather-for-several-cities
- Use the HTTParty gem https://github.com/jnunemaker/httparty
  - I ended up not needing this. For a moment I thought I needed to find latitude and longitude by city name so I had to make calls to https://openweathermap.org/api/geocoding-api. Upon further inspection, I realized I was getting the latitude and longitude from the Open Weather response. This code is in comments at the bottom for my own reference.
- Work with API keys and how to use a .env file and ENV variable to hide my API key. I think I need to learn a lot more about API key security (I hope I did it right!). Used https://github.com/bkeepers/dotenv
    - Accidentally added my env file... it was my first time. Used https://blog.gitguardian.com/rewriting-git-history-cheatsheet to sort it out.
- I got more practice with Sinatra, ERB and deploying to Heroku.
- I haven't done any CSS on this project, I will come back to that in the future.

Additional notes:
I didn't think I needed a database for this project since I am not saving a user's searches or any of the forecast data. If the user input is valid (matches a valid city AND country according to the OpenWeather API), the data is saved to the session hash. The reset button deletes the :city and :country keys in the session hash and the data is deleted from the screen. When a user searches a new city, the session :city and :country keys are overriden and thus the new weather forecast is called and displayed.