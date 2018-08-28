class Fuel < Product
    has_many :tanks, foreign_key: 'product_id'
    
    has_many :pump_reconciliation_totals, foreign_key: 'product_id'
    has_many :shift_inventory_updates, through: :pump_reconciliation_totals

    before_validation :serialize_symbols

    def beginning_inventory(date=nil, shift=3)
        values = []
        self.tanks.each do |tank|
            beginning_stock = tank.beginning_stock(date, shift)
            if !beginning_stock.nil?
                values << beginning_stock
            end
        end

        values.empty? ? nil : values.sum
    end

    def total_deliveries(date, shift)
        total = 0
        self.tanks.each { |tank| total += tank.total_deliveries(date, shift) }
        total
    end

    def total_dispensed(date, shift)
        total = 0
        self.tanks.each { |tank| total += tank.total_dispensed(date, shift) }
        total
    end

    def ending_inventory(date, shift)
        beginning_inventory = self.beginning_inventory(date, shift)
        total_deliveries = self.total_deliveries(date, shift)
        total_dispensed = self.total_dispensed(date, shift)

        if beginning_inventory.nil?
            nil
        else
            (beginning_inventory + total_deliveries) - total_dispensed
        end
    end

    def actual_count(date, shift)
        values = []
        self.tanks.each do |tank|
            actual_count = tank.actual_count(date, shift)
            if !actual_count.nil?
                values << actual_count
            end
        end

        values.empty? ? nil : values.sum
    end

    def difference(date, shift)
        values = []
        self.tanks.each do |tank|
            difference = tank.difference(date, shift)
            if !difference.nil?
                values << difference
            end
        end

        values.empty? ? nil : values.sum
    end

    def difference_pct(date, shift)
        difference = self.difference(date, shift)
        ending_inventory = self.ending_inventory(date, shift)

        if difference.nil? || ending_inventory.nil?
            nil
        else
            ending_inventory == 0 ? 0 : difference / ending_inventory
        end
    end

    def total_revenue(date, shift)
        values = []
        self.tanks.each do |tank|
            total_revenue = tank.total_revenue(date, shift)
            if !total_revenue.nil?
                values << total_revenue
            end
        end

        values.empty? ? nil : values.sum
    end


    def available_inventory(as_of=nil, shift=3)
        total = 0

        tanks = self.tanks
        self.tanks.each do |tank|
            stock = tank.available_stock(as_of, shift)
            total += stock
        end

        total
    end

    def forecast(date, month_range)
        daily_vol = []
        
        ( (date - 1.month).to_i ).step( ( date - (month_range + 1).months ).to_i, -1.day.to_i ) do |date_as_i|
            curr_date = DateTime.strptime(date_as_i.to_s, '%s')

            day_total = 0
            [1,2,3].each do |shift|
                day_total += self.total_dispensed(curr_date, shift)
            end

            if !daily_vol.any? { |v| v[:day] == curr_date.day }
                daily_vol << {
                    day: curr_date.day,
                    vol: [day_total]
                }
            else
                daily_vol.find { |v| v[:day] == curr_date.day }[:vol] << day_total
            end
        end

        daily_vol_avg = []
        daily_vol.each do |v|
            vol_arr = v[:vol]
            daily_vol_avg << { day: v[:day], vol_avg: vol_arr.sum / vol_arr.length }
        end

        vol_arr = []
        daily_vol_avg.each do |va|
            vol_arr << va[:vol_avg]
        end
        overall_avg = vol_arr.sum / vol_arr.length

        day_avg = daily_vol_avg.find { |va| va[:day] == date.day }[:vol_avg]
        seasonal_index = (overall_avg == 0 ? 0 : day_avg / overall_avg)
        
        expected_demand = 0
        self.tanks.each do |tank|
            tank.dipstick_measurements
                .joins(:shift_inventory_update)
                .order('shift_inventory_updates.date DESC')
                .first(3)
                .each do |dipstick_measurement|
                    expected_demand += dipstick_measurement.dispensed
                end
        end

        seasonal_index * expected_demand
    end

    private
        def serialize_symbols
            serialized = []
            self.symbols.each do |symbol|
                symbols = symbol.split(',').map { |sym| sym.strip }
                serialized = serialized + symbols
            end
            self.symbols = serialized
        end
end