class Tank < ApplicationRecord
    belongs_to :fuel, foreign_key: 'product_id'

    has_many :pump_nozzles
    has_many :product_deliveries

    has_many :fuel_sales
    has_many :shift_inventory_updates, through: :fuel_sales

    has_many :dipstick_measurements
    has_many :shift_inventory_updates, through: :dipstick_measurements

    def alias
        "UGT-#{self.tank_num}/#{self.fuel.symbols[0]}"
    end

    def day_totals(date)
        beginning_stock = (self.beginning_stock(date, 1) || 0)

        total_deliveries = 0
        [1,2,3].each do |shift|
            total_deliveries += self.total_deliveries(date, shift)
        end

        total_dispensed = 0
        [1,2,3].each do |shift|
            total_dispensed += self.total_dispensed(date, shift)
        end

        ending_stock = nil
        if !beginning_stock.nil?
            ending_stock = (beginning_stock + total_deliveries) - total_dispensed
        end

        actual_count = nil
        [3,2,1].each do |shift|
            tank_actual_count = self.actual_count(date, shift)
            if !tank_actual_count.nil?
                actual_count = tank_actual_count
                break
            end
        end
        
        diff = nil
        if !ending_stock.nil? && !actual_count.nil?
            diff = actual_count - ending_stock
        end

        diff_pct = nil
        if !diff.nil?
            diff_pct = ending_stock == 0 ? 0 : (diff / ending_stock)
        end

        {
            beginning_stock: beginning_stock,
            total_deliveries: total_deliveries,
            total_dispensed: total_dispensed,
            ending_stock: ending_stock,
            actual_count: actual_count,
            difference: diff,
            difference_pct: diff_pct
        }
    end

    def beginning_stock(date=nil, shift=3)
        dipstick_measurements = self.dipstick_measurements
            .includes(:shift_inventory_update)
            .order('shift_inventory_updates.date ASC, shift_inventory_updates.shift ASC')
    
        if date.nil?
            dipstick_measurements.last.beginning_amt
        else
            filtered_dm = dipstick_measurements.where(
                'shift_inventory_updates.date=? AND shift_inventory_updates.shift=?',
                date,
                shift
            )

            filtered_dm.empty? ? nil : filtered_dm.last.beginning_amt
        end
    end

    def total_deliveries(date, shift)
        product_deliveries = self.product_deliveries
            .includes(:delivery => :shift_inventory_update)
            .references(:delivery, :shift_inventory_update)
            .where(
                'shift_inventory_updates.date=? AND shift_inventory_updates.shift=?',
                date,
                shift
            )

        product_deliveries.empty? ? 0 : product_deliveries.sum(:qty_delivered) 
    end

    def total_dispensed(date, shift)
        dipstick_measurements = self.dipstick_measurements
            .includes(:shift_inventory_update)
            .references(:shift_inventory_update)
            .where(
                'shift_inventory_updates.date=? AND shift_inventory_updates.shift=?',
                date,
                shift
            )

        dipstick_measurements.empty? ? 0 : dipstick_measurements.last.dispensed
    end

    def ending_stock(date, shift)
        beginning = self.beginning_stock(date, shift)
        total_deliveries = self.total_deliveries(date, shift)
        total_dispensed = self.total_dispensed(date, shift)

        if beginning.nil?
            nil
        else
            (beginning + total_deliveries) - total_dispensed
        end
    end

    def actual_count(date, shift)
        dipstick_measurements = self.dipstick_measurements
            .includes(:shift_inventory_update)
            .references(:shift_inventory_update)
            .where(
                'shift_inventory_updates.date=? AND shift_inventory_updates.shift=?',
                date,
                shift
            )

        dipstick_measurements.empty? ? nil : dipstick_measurements.last.converted_vol
    end

    def difference(date, shift)
        dipstick_measurements = self.dipstick_measurements
            .includes(:shift_inventory_update)
            .references(:shift_inventory_update)
            .where(
                'shift_inventory_updates.date=? AND shift_inventory_updates.shift=?',
                date,
                shift
            )

        ending_stock = self.ending_stock(date, shift)
        actual_count = self.actual_count(date, shift)
        if ending_stock.nil? || actual_count.nil?
            nil
        else
            actual_count - ending_stock
        end
    end

    def difference_pct(date, shift)
        difference = self.difference(date, shift)
        ending_stock = self.ending_stock(date, shift)

        if difference.nil? || ending_stock.nil?
            nil
        else
            ending_stock == 0 ? 0 : (difference / ending_stock)
        end
    end

    def total_revenue(date, shift)
        total_dispensed = self.total_dispensed(date, shift)
        price = self.fuel.price(date)

        if total_dispensed.nil? || price.nil?
            nil
        else
            total_dispensed * price
        end
    end

    def available_stock(as_of=nil, shift=3)
        dipstick_measurements = self.dipstick_measurements
            .includes(:shift_inventory_update)
            .references(:shift_inventory_update)
            .order('shift_inventory_updates.date ASC, shift_inventory_updates.shift ASC')

        if as_of.nil?
            dipstick_measurements.last.ending_amt
        else
            find_by_date_shift = dipstick_measurements
                .where('shift_inventory_updates.date = ? AND shift_inventory_updates.shift = ?', as_of, shift)
                .order('shift_inventory_updates.date ASC, shift_inventory_updates.shift ASC')

            find_by_date = dipstick_measurements
                .where('shift_inventory_updates.date <= ?', as_of)
                .order('shift_inventory_updates.date ASC, shift_inventory_updates.shift ASC')

            if find_by_date_shift.empty?
                (find_by_date.empty? ? 0 : find_by_date.last.ending_amt)
            else
                find_by_date_shift.last.ending_amt
            end
        end
    end




end