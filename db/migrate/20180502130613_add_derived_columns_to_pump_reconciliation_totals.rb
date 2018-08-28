class AddDerivedColumnsToPumpReconciliationTotals < ActiveRecord::Migration[5.0]
  def change
    add_column :pump_reconciliation_totals, :beginning_bal, :decimal
    add_column :pump_reconciliation_totals, :calibration, :decimal
    add_column :pump_reconciliation_totals, :dispensed, :decimal
  end
end
