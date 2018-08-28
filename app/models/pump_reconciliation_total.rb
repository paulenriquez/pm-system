class PumpReconciliationTotal < ApplicationRecord
    include ShiftInventoryUpdates::LinkedRecord
    include ShiftInventoryUpdates::DerivedColumnsCalculator
    
    LINK_REF_COL = :product_id
    DERIVED_COLUMNS = [:beginning_bal, :calibration, :dispensed]

    belongs_to :fuel, foreign_key: 'product_id'
    belongs_to :shift_inventory_update

    private
        def calc_beginning_bal
            prev = self.nearest_prev
            prev.nil? ? nil : prev.ending_bal
        end

        def calc_calibration
            self.shift_inventory_update.total_calibrations(:product, self.product_id)
        end

        def calc_dispensed
            beginning_bal = self.beginning_bal
            beginning_bal.nil? ? nil : (self.ending_bal - self.calibration) - beginning_bal
        end
end
