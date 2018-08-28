class InventoryAndSalesController < ApplicationController
    include ApplicationHelper

    # Makes sure that all data dependent on shift inventory updates will be queried and showed
    
    def index
        @date = params[:date].present? ? Date.parse(params[:date]) : DateTime.now
        
        @tanks = Tank.all
        @fuels = Fuel.all
    end

    def async_overall_daily_summary
        date = params[:date].present? ? Date.parse(params[:date]) : DateTime.now

        @day_totals = {
            overall_revenue: ShiftInventoryUpdate.day_overall_revenue(date),
            overall_revenue_chg: ShiftInventoryUpdate.day_overall_revenue_chg(date),
            fuel_revenue: ShiftInventoryUpdate.day_fuel_revenue(date),
            fuel_revenue_chg: ShiftInventoryUpdate.day_fuel_revenue_chg(date),
            non_fuel_revenue: ShiftInventoryUpdate.day_non_fuel_revenue(date),
            non_fuel_revenue_chg: ShiftInventoryUpdate.day_non_fuel_revenue_chg(date)
        }

        render partial: 'overall_daily_summary'
    end

    def async_fuel_daily_summary
        @date = params[:date].present? ? Date.parse(params[:date]) : DateTime.now
        
        @tanks = Tank.all
        @fuels = Fuel.all

        render partial: 'fuel_daily_summary'
    end

end
