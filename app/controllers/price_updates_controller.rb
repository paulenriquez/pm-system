class PriceUpdatesController < ApplicationController
    # Calls the method :get_all_required_records
    before_action :get_all_required_records

    # Basic CRUD (Create, Read, Update, Destroy) with Search Functionality
    def index
    end

    def new
        @price_update = PriceUpdate.new
    end

    def create
        @price_update = PriceUpdate.new price_update_params
        if @price_update.save
            redirect_to price_updates_path(@price_update)
        else
            render :new
        end
    end

    def show
        @price_update = PriceUpdate.find params[:id]
    end

    def edit
        @price_update = PriceUpdate.find params[:id]
    end

    def update
        @price_update = PriceUpdate.find params[:id]
        if @price_update.update price_update_params
            redirect_to price_updates_path(@price_update)
        else
            render :edit
        end
    end

    def destroy
        @price_update = PriceUpdate.find params[:id]
        @price_update.destroy
    end

    private
        def get_all_required_records
            @price_updates = PriceUpdate.all
            @products = Product.all
        end
        def price_update_params
            params.require(:price_update).permit!
        end
end