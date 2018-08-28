class Calibration < ApplicationRecord
    belongs_to :pump_nozzle
    belongs_to :shift_inventory_update
end
