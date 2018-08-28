class PumpMeterReading < ApplicationRecord
    include ShiftInventoryUpdates::LinkedRecord
    include ShiftInventoryUpdates::DerivedColumnsCalculator

    LINK_REF_COL = :pump_nozzle_id
    DERIVED_COLUMNS = [:beginning_bal, :calibration, :dispensed]

    belongs_to :pump_nozzle
    belongs_to :shift_inventory_update

    after_save :write_derived

    def revenue
        dispensed = self.dispensed
        fuel_price = self.pump_nozzle.tank.fuel.price(self.shift_inventory_update.date)
        if dispensed.nil? || fuel_price.nil?
            nil
        else
            dispensed * fuel_price
        end
    end

    private
        def calc_beginning_bal
            prev = self.nearest_prev
            prev.nil? ? nil : prev.ending_bal
        end

        def calc_calibration
            calibration = self.pump_nozzle.calibrations
                .find_by(shift_inventory_update_id: self.shift_inventory_update_id)

            calibration.nil? ? 0 : calibration.amount
        end

        def calc_dispensed
            beginning_bal = self.beginning_bal
            beginning_bal.nil? ? nil : (self.ending_bal - self.calibration) - beginning_bal
        end
end
