class ProductsController < ApplicationController

    # Basic CRUD (Create, Read, Update, Destroy) with Search Functionality
    def index
        @products = Product.all
    end
    
    def new
        @product = Product.new
    end

    def create
        @product = Product.new products_params
        if @product.save
            redirect_to products_path(@product)
        else
            render :new
        end
    end

    def show
        @product = Product.find params[:id]
    end

    def edit
        @product = Product.find params[:id]
    end

    def update
        @product = Product.find params[:id]
        if @product.update products_params
            redirect_to products_path(@product)
        else
            render :edit
        end
    end

    def destroy
        @product = Product.find params[:id]
        @product.destroy
    end

    private
        def products_params
            params.require(:product).permit!
        end
end