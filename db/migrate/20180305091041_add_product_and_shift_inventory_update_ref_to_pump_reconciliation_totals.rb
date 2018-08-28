class AddProductAndShiftInventoryUpdateRefToPumpReconciliationTotals < ActiveRecord::Migration[5.0]
  def change
    add_reference :pump_reconciliation_totals, :product, index: true, foreign_key: true
    add_reference :pump_reconciliation_totals, :shift_inventory_update, index: true, foreign_key: true
  end
end
