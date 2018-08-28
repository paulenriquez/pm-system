class Delivery < ApplicationRecord
    has_many :product_deliveries, inverse_of: :delivery, dependent: :destroy
    has_many :products, through: :product_deliveries
    accepts_nested_attributes_for :product_deliveries, allow_destroy: true

    belongs_to :shift_inventory_update

    # validate :validate_delivery

    # private
    #     def validate_delivery
    #         # Shift Time
            
    #     end
end
