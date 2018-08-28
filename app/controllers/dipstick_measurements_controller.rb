class DipstickMeasurementsController < ApplicationController
    
    # Basic CRUD (Create, Read, Update, Destroy) with Search Functionality
    
    def index
        @dipstick_measurements = DipstickMeasurement.all
    end

    def new
        @dipstick_measurement = DipstickMeasurement.new
    end

    def create
        @dipstick_measurement = DipstickMeasurement.new dipstick_measurement_params
        if @dipstick_measurement.save
            redirect_to dipstick_measurements_path(@dipstick_measurement)
        else
            render :new
        end
    end

    def show
        @dipstick_measurement = DipstickMeasurement.find params[:id]
    end

    def edit
        @dipstick_measurement = DipstickMeasurement.find params[:id]
    end

    def update
        @dipstick_measurement = DipstickMeasurement.find params[:id]
        if @dipstick_measurement.update dipstick_measurement_params
            redirect_to dipstick_measurements_path(@dipstick_measurement)
        else
            render :edit
        end
    end

    def destroy
        @dipstick_measurement = DipstickMeasurement.find params[:id]
        @dipstick_measurement.destroy
    end

    private
        def dipstick_measurement_params
            params.require(:dipstick_measurement).permit!
        end
end
