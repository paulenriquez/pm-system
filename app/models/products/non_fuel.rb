class NonFuel < Product
    has_many :non_fuel_sales, foreign_key: 'product_id'
    has_many :shift_inventory_updates, through: :non_fuel_sales

    def available_inventory(as_of=nil, shift=3)
        total = 0

        total
    end
end