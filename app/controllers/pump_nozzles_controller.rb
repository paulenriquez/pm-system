class PumpNozzlesController < ApplicationController
    before_action :get_all_required_records
    
    # Basic CRUD (Create, Read, Update, Destroy) with Search Functionality
    def index
    end

    def new
        @pump_nozzle = PumpNozzle.new
    end

    def create
        @pump_nozzle = PumpNozzle.new pump_nozzle_params
        if @pump_nozzle.save
            redirect_to pump_nozzles_path(@pump_nozzle)
        else
            render :new
        end
    end

    def show
        @pump_nozzle = PumpNozzle.find params[:id]
    end

    def edit
        @pump_nozzle = PumpNozzle.find params[:id]
    end

    def update
        @pump_nozzle = PumpNozzle.find params[:id]
        if @pump_nozzle.update pump_nozzle_params
            redirect_to pump_nozzles_path(@pump_nozzle)
        else
            render :edit
        end
    end

    def destroy
        @pump_nozzle = PumpNozzle.find params[:id]
        @pump_nozzle.destroy
    end

    private
        def get_all_required_records
            @pump_nozzles = PumpNozzle.all
            @fuels = Fuel.all
        end
        def pump_nozzle_params
            params.require(:pump_nozzle).permit!
        end
end