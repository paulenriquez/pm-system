class TanksController < ApplicationController
    before_action :get_all_required_records

    # Basic CRUD (Create, Read, Update, Destroy) with Search Functionality
    def index
    end

    def new
        @tank = Tank.new
    end

    def create
        @tank = Tank.new tank_params
        if @tank.save
            redirect_to tanks_path(@tank)
        else
            render :new
        end
    end

    def show
        @tank = Tank.find params[:id]
    end

    def edit
        @tank = Tank.find params[:id]
    end

    def update
        @tank = Tank.find params[:id]
        if @tank.update tank_params
            redirect_to tanks_path(@tank)
        else
            render :edit
        end
    end

    def destroy
        @tank = Tank.find params[:id]
        @tank.destroy
    end

    def api_get_next_alias
        product_id = params[:product_id]

        result = {status: '', message: '', data: {}}
        if Fuel.exists? product_id
            result[:status] = 'ok'
            result[:message] = ''

            @fuel = Fuel.find(product_id)
            result[:data][:next_alias] = "UGT #{@fuel.symbols[0]}-#{@fuel.tanks.count + 1}"

            result[:data][:ordinalized_tank_num] = "#{(@fuel.tanks.count + 1).ordinalize}"
        else
            result[:status] = 'error'
            result[:message] = "Can't find Fuel with id #{product_id}"
        end

        render json: result
    end

    private
        def get_all_required_records
            @tanks = Tank.all
            @fuels = Fuel.all
        end
        def tank_params
            params.require(:tank).permit!
        end
end
