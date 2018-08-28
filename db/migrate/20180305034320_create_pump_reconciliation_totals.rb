class CreatePumpReconciliationTotals < ActiveRecord::Migration[5.0]
  def change
    create_table :pump_reconciliation_totals do |t|
      t.decimal :ending_bal
      
      t.timestamps
    end
  end
end
