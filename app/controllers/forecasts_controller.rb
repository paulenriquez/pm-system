class ForecastsController < ApplicationController

    def index
        @date = DateTime.now
    end

    def async_fuel_forecasts
        @date = DateTime.now
        @fuels = Fuel.all
        render partial: 'fuel_forecasts'
    end
end
