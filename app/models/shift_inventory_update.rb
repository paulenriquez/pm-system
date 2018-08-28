class ShiftInventoryUpdate < ApplicationRecord
    include ShiftInventoryUpdates::LinkedRecord

    LINK_REF_COL = nil

    has_many :deliveries, inverse_of: :shift_inventory_update, dependent: :destroy
    accepts_nested_attributes_for :deliveries, allow_destroy: true, reject_if: :reject_deliveries

    has_many :fuel_sales, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :tanks, through: :fuel_sales
    accepts_nested_attributes_for :fuel_sales, allow_destroy: true, reject_if: :reject_fuel_sales

    has_many :dipstick_measurements, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :tanks, through: :dipstick_measurements
    accepts_nested_attributes_for :dipstick_measurements, allow_destroy: true, reject_if: :reject_dipstick_measurements

    has_many :calibrations, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :pump_nozzles, through: :calibrations
    accepts_nested_attributes_for :calibrations, allow_destroy: true, reject_if: :reject_calibrations
    
    has_many :pump_meter_readings, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :pump_nozzles, through: :pump_meter_readings
    accepts_nested_attributes_for :pump_meter_readings, allow_destroy: true, reject_if: :reject_pump_meter_readings

    has_many :pump_reconciliation_totals, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :fuels, through: :pump_reconciliation_totals
    accepts_nested_attributes_for :pump_reconciliation_totals, allow_destroy: true, reject_if: :reject_pump_reconciliation_totals

    has_many :non_fuel_sales, inverse_of: :shift_inventory_update, dependent: :destroy
    has_many :non_fuels, through: :non_fuel_sales
    accepts_nested_attributes_for :non_fuel_sales, allow_destroy: true

    def self.hours(shift)
        hours_hash = {
            '1': [ Time.parse('06:00 AM'), Time.parse('02:00 PM') ],
            '2': [ Time.parse('02:00 PM'), Time.parse('10:00 PM') ],
            '3': [ Time.parse('10:00 PM'), Time.parse('06:00 AM') ]
        }
        hours_hash[shift.to_s.to_sym]
    end

    def self.hours_str(shift)
        hours_hash = {
            '1': '6:00 AM - 2:00 PM',
            '2': '2:00 PM - 10:00 PM',
            '3': '10:00 PM - 6:00 AM'
        }
        hours_hash[shift.to_s.to_sym]
    end

    def self.shift_iterator(date, shift, move_by)
        curr_date = date
        curr_shift = shift

        movement = 0
        while movement != move_by
            if move_by > 0
                if curr_shift == 3
                    curr_date += 1.day
                    curr_shift = 1
                else
                    curr_shift += 1
                end
            elsif move_by < 0
                if curr_shift == 1
                    curr_date -= 1.day
                    curr_shift = 3
                else
                    curr_shift -= 1
                end
            end

            movement += (move_by / move_by.abs)
        end

        { date: curr_date, shift: curr_shift }
    end

    def self.day_overall_revenue(date)
        shift_inventory_updates = ShiftInventoryUpdate.where(date: date)

        total = 0
        shift_inventory_updates.each { |siu| total += (siu.overall_revenue || 0) }
        total
    end

    def self.day_overall_revenue_chg(date)
        prev_day_overall_revenue = ShiftInventoryUpdate.day_overall_revenue(date - 1.day)
        day_overall_revenue = ShiftInventoryUpdate.day_overall_revenue(date)
    
        diff = day_overall_revenue - prev_day_overall_revenue

        prev_day_overall_revenue == 0 ? nil : diff / prev_day_overall_revenue
    end

    def self.day_fuel_revenue(date)
        shift_inventory_updates = ShiftInventoryUpdate.where(date: date)

        total = 0
        shift_inventory_updates.each { |siu| total += (siu.fuel_revenue || 0) }
        total
    end

    def self.day_fuel_revenue_chg(date)
        prev_day_fuel_revenue = ShiftInventoryUpdate.day_fuel_revenue(date - 1.day)
        day_fuel_revenue = ShiftInventoryUpdate.day_fuel_revenue(date)
    
        diff = day_fuel_revenue - prev_day_fuel_revenue

        prev_day_fuel_revenue == 0 ? nil : diff / prev_day_fuel_revenue
    end

    def self.day_non_fuel_revenue(date)
        shift_inventory_updates = ShiftInventoryUpdate.where(date: date)

        total = 0
        shift_inventory_updates.each { |siu| total += (siu.non_fuel_revenue || 0) }
        total
    end

    def self.day_non_fuel_revenue_chg(date)
        prev_day_non_fuel_revenue = ShiftInventoryUpdate.day_non_fuel_revenue(date - 1.day)
        day_non_fuel_revenue = ShiftInventoryUpdate.day_non_fuel_revenue(date)
    
        diff = day_non_fuel_revenue - prev_day_non_fuel_revenue

        prev_day_non_fuel_revenue == 0 ? nil : diff / prev_day_non_fuel_revenue
    end

    def prev_by_shift(shift)
        shift_inventory_updates = ShiftInventoryUpdate
            .order(date: :asc, shift: :asc)
            .where(shift: shift)

        id_shift_arr = shift_inventory_updates.pluck(:id, :shift).map{ |id, shift| {id: id, shift: shift} }
        prev_index = id_shift_arr.index { |i| i[:id] == self.id } - 1
        if prev_index >= 0
            ShiftInventoryUpdate.find(id_shift_arr[prev_index][:id])
        else
            nil
        end
    end

    def empty?
        self.deliveries.empty? && 
            self.calibrations.empty? &&
            self.pump_meter_readings.empty? &&
            self.pump_reconciliation_totals.empty? &&
            self.dipstick_measurements.empty?
    end

    def delivery_summary(summary_method)
        def total_deliveries_by_product
            totals = []

            self.deliveries
                .joins(:product_deliveries)
                .group('product_deliveries.product_id', 'deliveries.delivery_type')
                .sum('product_deliveries.qty_delivered')
                .each { |k,v| totals << { product_id: k[0], type: k[1], total_delivered: v } }
            
            totals.each do |total|
                stock_after_delivery = 0
                prev_shift_inventory_update = self.nearest_prev

                prev_stock = 0
                if !prev_shift_inventory_update.nil?
                    prev_stock = Product.find(total[:product_id]).available_inventory(
                        as_of=prev_shift_inventory_update.date,
                        shift=prev_shift_inventory_update.shift
                    )
                end
                stock_after_delivery = prev_stock + total[:total_delivered]
                total[:stock_after_delivery] = stock_after_delivery
            end

            totals
        end

        def total_fuel_deliveries_by_tank
            totals = []

            self.deliveries
                .where(delivery_type: 'Fuel')
                .joins(:product_deliveries => :tank)
                .group('tanks.id', 'tanks.tank_num')
                .sum('product_deliveries.qty_delivered')
                .each { |k,v| totals << { tank_id: k[0], tank_num: k[1], total_delivered: v } }

            totals.each do |total|
                stock_after_delivery = 0
                prev_shift_inventory_update = self.nearest_prev

                prev_stock = 0
                if !prev_shift_inventory_update.nil?
                    prev_stock = Tank.find(total[:tank_id]).available_stock(
                        as_of=prev_shift_inventory_update.date,
                        shift=prev_shift_inventory_update.shift
                    )
                end
                stock_after_delivery = prev_stock + total[:total_delivered]
                total[:stock_after_delivery] = stock_after_delivery
            end

            totals
        end

        method(summary_method).call
    end

    def calibration_summary(summary_method)
        def total_calibrations_by_fuel
            totals = []

            self.calibrations
                .joins(:pump_nozzle => { :tank => :fuel })
                .group('products.id')
                .sum('calibrations.amount')
                .each { |k,v| totals << { fuel_id: k, total_calibrations: v } }

            totals
        end

        def total_calibrations_by_tank
            totals = []

            self.calibrations
                .joins(:pump_nozzle => :tank)
                .group('tanks.id')
                .sum('calibrations.amount')
                .each { |k,v| totals << { tank_id: k, total_calibrations: v } }

            totals
        end

        method(summary_method).call
    end

    def pump_meter_reading_summary(summary_method)
        def all_totals_by_fuel
            totals = []
            self.pump_meter_readings.includes(:pump_nozzle => { :tank => :fuel }).each do |pump_meter_reading|
                if !totals.any? { |t| t[:fuel_id] == pump_meter_reading.pump_nozzle.tank.fuel.id }
                    total_calibrations = self.total_calibrations(:product, pump_meter_reading.pump_nozzle.tank.fuel.id)

                    totals << {
                        fuel_id: pump_meter_reading.pump_nozzle.tank.fuel.id,
                        total_beg_bal: pump_meter_reading.beginning_bal,
                        total_end_bal: pump_meter_reading.ending_bal,
                        total_calibrations: total_calibrations,
                        total_dispensed: pump_meter_reading.dispensed,
                        total_revenue: pump_meter_reading.revenue
                    }
                else
                    summary_item = totals.find{ |t| t[:fuel_id] == pump_meter_reading.pump_nozzle.tank.fuel.id }

                    if !(summary_item[:total_beg_bal].nil? || pump_meter_reading.beginning_bal.nil?)
                        summary_item[:total_beg_bal] += pump_meter_reading.beginning_bal
                    end

                    summary_item[:total_end_bal] += pump_meter_reading.ending_bal

                    if !(summary_item[:total_dispensed].nil? || pump_meter_reading.dispensed.nil?)
                        summary_item[:total_dispensed] += pump_meter_reading.dispensed
                    end

                    if !(summary_item[:total_revenue].nil? || pump_meter_reading.revenue.nil?)
                        summary_item[:total_revenue] += pump_meter_reading.revenue
                    end
                end
            end
            totals
        end

        def all_totals_by_tank
            totals = []

            self.pump_meter_readings.includes(:pump_nozzle => { :tank => :fuel }).each do |pump_meter_reading|
                if !totals.any? { |t| t[:tank_id] == pump_meter_reading.pump_nozzle.tank_id }
                    total_calibrations = self.total_calibrations(:tank, pump_meter_reading.pump_nozzle.tank_id)

                    totals << {
                        tank_id: pump_meter_reading.pump_nozzle.tank_id,
                        total_beg_bal: pump_meter_reading.beginning_bal,
                        total_end_bal: pump_meter_reading.ending_bal,
                        total_calibrations: total_calibrations,
                        total_dispensed: pump_meter_reading.dispensed,
                        total_revenue: pump_meter_reading.revenue
                    }
                else
                    summary_item = totals.find{ |t| t[:tank_id] == pump_meter_reading.pump_nozzle.tank_id }

                    if !(summary_item[:total_beg_bal].nil? || pump_meter_reading.beginning_bal.nil?)
                        summary_item[:total_beg_bal] += pump_meter_reading.beginning_bal
                    end

                    summary_item[:total_end_bal] += pump_meter_reading.ending_bal

                    if !(summary_item[:total_dispensed].nil? || pump_meter_reading.dispensed.nil?)
                        summary_item[:total_dispensed] += pump_meter_reading.dispensed
                    end

                    if !(summary_item[:total_revenue].nil? || pump_meter_reading.revenue.nil?)
                        summary_item[:total_revenue] += pump_meter_reading.revenue
                    end
                end
            end
            
            totals.sort_by! { |s| s[:tank_num] }
            totals
        end

        def this_and_prt_match_check
            differences = []
            pmr_totals = all_totals_by_fuel

            # pmr_totals.each do |summary_item|
            #     prt = self.pump_reconciliation_totals
            #         .find_by(product_id: summary_item[:fuel_id])

            #     prt_dispensed =
            #     if !prt.nil?
            #         .dispensed

            #     diff = (summary_item[:total_dispensed] - prt_dispensed).abs unless summary_item[:total_dispensed].nil? || prt_dispensed.nil?
            #     diff_pct = (diff / prt_dispensed).abs unless diff.nil?

            #     differences << {
            #         fuel_id: summary_item[:fuel_id],
            #         diff: diff,
            #         diff_pct: diff_pct
            #     }
            # end

            differences
        end

        def this_and_dm_match_check
            differences = []
            self.dipstick_measurements.each do |dipstick_measurement|
                differences << {
                    tank_id: dipstick_measurement.tank_id,
                    tank_num: dipstick_measurement.tank.tank_num,
                    diff: dipstick_measurement.difference.abs,
                    diff_pct: dipstick_measurement.difference_pct.abs 
                }
            end

            differences.sort_by! { |s| s[:tank_num] }
            differences
        end

        def revenue_by_pump_nozzle
            revenues = []
            self.pump_meter_readings.includes(:pump_nozzle => { :tank => :fuel }).each do |pump_meter_reading|
                revenues << {
                    pump_nozzle_id: pump_meter_reading.pump_nozzle_id,
                    pump_island_num: pump_meter_reading.pump_nozzle.pump_island_num,
                    loading_point_num: pump_meter_reading.pump_nozzle.loading_point_num,
                    nozzle_num: pump_meter_reading.pump_nozzle.nozzle_num,
                    revenue: (pump_meter_reading.revenue || 0)
                }
            end
            revenues.sort! { |a,b| [ a[:pump_island_num], a[:loading_point_num], a[:nozzle_num] ] <=> [ b[:pump_island_num], b[:loading_point_num], b[:nozzle_num] ] }
            revenues
        end

        method(summary_method).call
    end

    def pump_reconciliation_total_summaries
        # pump_meter_reading_summaries = self.pump_meter_reading_summaries
        # differences = []

        # self.pump_reconciliation_totals.each do |pump_reconciliation_total|
        #     pmr_total_end_bal = pump_meter_reading_summaries.detect { |s| s[:fuel_id] == pump_reconciliation_total.product_id }[:total_end_bal]
        #     if !pmr_total_end_bal.nil?
        #         pmr_prt_diff = (pump_reconciliation_total.ending_bal - pmr_total_end_bal).abs

        #         differences << {
        #             fuel_id: pump_reconciliation_total.product_id,
        #             pmr_prt_diff: pmr_prt_diff
        #         }
        #     end
        # end
        # differences
        []
    end

    def total_calibrations(ref_table, id)
        self.calibrations
            .where(shift_inventory_update_id: self.id)
            .joins(:pump_nozzle => {:tank => :fuel})
            .where("#{ref_table.to_s.pluralize}.id=?", id)
            .sum(:amount)
    end

    def overall_revenue
        self.fuel_revenue + self.non_fuel_revenue
    end

    def overall_revenue_chg
        prev = self.prev_by_shift(self.shift)
        if !prev.nil?
            prev_revenue = prev.overall_revenue
            curr_revenue = self.overall_revenue

            if prev_revenue == 0 || self.pump_reconciliation_totals.empty?
                nil
            else
                (curr_revenue - prev_revenue) / prev_revenue
            end
        else
            nil
        end
    end

    def fuel_revenue
        total = 0

        Fuel.all.each do |fuel|
            total += (fuel.total_revenue(self.date, self.shift) || 0) 
        end

        total
    end

    def fuel_revenue_chg
        prev = self.prev_by_shift(self.shift)
        if !prev.nil?
            prev_revenue = prev.fuel_revenue
            curr_revenue = self.fuel_revenue

            if prev_revenue == 0 || self.pump_reconciliation_totals.empty?
                nil
            else
                (curr_revenue - prev_revenue) / prev_revenue
            end
        else
            nil
        end
    end

    def non_fuel_revenue
        0
    end

    def non_fuel_revenue_chg
        prev = self.prev_by_shift(self.shift)
        if !prev.nil?
            prev_revenue = prev.non_fuel_revenue
            curr_revenue = self.non_fuel_revenue

            if prev_revenue == 0 || self.empty?
                nil
            else
                (curr_revenue - prev_revenue) / prev_revenue
            end
        else
            nil
        end
    end

    private
        def reject_deliveries(attributes)
            false
        end
        def reject_fuel_sales(attributes)
            attributes['dispensed'].blank?
        end
        def reject_dipstick_measurements(attributes)
            attributes['converted_vol'].blank?
        end
        def reject_calibrations(attributes)
            attributes['amount'].blank?
        end
        def reject_pump_meter_readings(attributes)
            attributes['ending_bal'].blank?
        end
        def reject_pump_reconciliation_totals(attributes)
            attributes['ending_bal'].blank?
        end
end