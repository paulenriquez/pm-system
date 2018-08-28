class PumpNozzle < ApplicationRecord
    belongs_to :tank

    has_many :calibrations
    has_many :pump_meter_readings
    has_many :shift_inventory_updates, through: [:calibrations, :pump_meter_readings]

    def alias
        "Pump Nozzle P#{self.pump_island_num}-L#{self.loading_point_num}-#{self.tank.fuel.symbols[0]}"
    end
end