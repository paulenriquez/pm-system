class Product < ApplicationRecord
    has_many :product_price_updates
    has_many :price_updates, through: :product_price_updates

    has_many :product_deliveries
    has_many :deliveries, through: :product_deliveries

    validates :name, presence: true
    
    def price(as_of=nil)
        price_updates = self.product_price_updates.order(effective_on: :asc)
        if as_of.nil?
            price_updates.last.new_price
        else
            filtered_price_updates = price_updates.where('effective_on <= ?', as_of)
            if filtered_price_updates.empty?
                nil
            else
                filtered_price_updates.last.new_price
            end
        end
    end
end