class DipstickMeasurement < ApplicationRecord
    include ShiftInventoryUpdates::LinkedRecord
    include ShiftInventoryUpdates::DerivedColumnsCalculator

    LINK_REF_COL = :tank_id
    DERIVED_COLUMNS = [:beginning_amt, :deliveries, :dispensed, :ending_amt]
    
    belongs_to :tank
    belongs_to :shift_inventory_update

    after_save :write_derived

    def difference
        self.converted_vol - self.ending_amt
    end

    def difference_pct
        converted_vol = self.converted_vol
        converted_vol == 0 ? 0 : self.difference / converted_vol
    end

    private
        def calc_beginning_amt
            prev = self.nearest_prev
            prev.nil? ? nil : prev.ending_amt
        end

        def calc_deliveries
            product_deliveries = self.tank.product_deliveries
                .joins(:delivery)
                .where('deliveries.shift_inventory_update_id = ?', self.shift_inventory_update_id)

            product_deliveries.empty? ? 0 : product_deliveries.sum(:qty_delivered)
        end

        def calc_dispensed
            fuel_sale = self.shift_inventory_update.fuel_sales.find_by(tank_id: self.tank_id)
            fuel_sale.nil? ? 0 : fuel_sale.dispensed
        end

        def calc_ending_amt
            beginning_amt = self.beginning_amt
            deliveries = self.deliveries
            dispensed = self.dispensed

            beginning_amt.nil? ? self.converted_vol : ((beginning_amt + deliveries) - dispensed)
        end
end
