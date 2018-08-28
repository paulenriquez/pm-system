class ChartsController < ApplicationController
    
    # Searches all the revenue by shift by date of all the available data
    def fuel_revenue_by_shift
        # data = { name: 'Fuel Revenue', data: {} }
        data = {}

        date = DateTime.parse(params[:date])
        shift = params[:shift].to_i

        date_shift_iter = []
        (-3).upto(0).each do |i|
            date_shift_iter << ShiftInventoryUpdate.shift_iterator(date, shift, i)
        end

        date_shift_iter.each do |date_shift|
            shift_inventory_update = ShiftInventoryUpdate.find_by(date: date_shift[:date], shift: date_shift[:shift])

            data_point = shift_inventory_update.nil? ? nil : shift_inventory_update.fuel_revenue
            data["#{date_shift[:date].strftime('%b %d')} - S##{date_shift[:shift]}"] = data_point
        end
        

        render json: data
    end

    # Searches all the fuel volume by shift by date from all the available data
    def fuel_volume_by_day
        data = []

        fuels = Fuel.all
        date = DateTime.parse(params[:date])
        
        fuels.each do |fuel|
            dataset = { name: fuel.symbols[0], data: {} }
            ( (date.to_i - 7.days).step( date.to_i, 1.day ) ).each do |curr_date|
                parsed_date = DateTime.strptime(curr_date.to_s, '%s')

                pt_label = "#{parsed_date.strftime('%b %d (%a)')}"
                pt_data = 0

                [1,2,3].each do |shift|
                    pt_data += fuel.total_dispensed(parsed_date, shift)
                end
                
                dataset[:data][pt_label] = pt_data
            end
            data << dataset
        end

        render json: data
    end

    def day_fuel_volume_breakdown
        data = {}

        fuels = Fuel.all
        date = DateTime.parse(params[:date])

        fuels.each do |fuel|
            total_dispensed = 0
            [1,2,3].each do |shift|
                total_dispensed += fuel.total_dispensed(date, shift)
            end
            data[fuel.symbols[0]] = total_dispensed
        end

        render json: data
    end

    def fuel_volume_by_shift
        data = []

        fuels = Fuel.all
        date = DateTime.parse(params[:date])
        shift = params[:shift].to_i

        date_shift_iter = []
        (-3).upto(0).each do |i|
            date_shift_iter << ShiftInventoryUpdate.shift_iterator(date, shift, i)
        end


        fuels.each do |fuel|
            dataset = { name: fuel.symbols[0], data: {} }
            
            date_shift_iter.each do |date_shift|
                pt_label = "#{date_shift[:date].strftime('%b %d')} - S#{date_shift[:shift]}"
                dataset[:data][pt_label] = fuel.total_dispensed(date_shift[:date], date_shift[:shift])
            end

            data << dataset
        end

        render json: data
    end
    
    # Searches the amount of fuel of each product by shift by date
    def shift_fuel_volume_breakdown
        data = {}
        
        fuels = Fuel.all
        date = DateTime.parse(params[:date])
        shift = params[:shift].to_i

        fuels.each { |fuel| data[fuel.symbols[0]] = fuel.total_dispensed(date, shift) }
    
        render json: data
    end
    
end
