class PriceUpdate < ApplicationRecord
    has_many :product_price_updates, inverse_of: :price_update
    has_many :products, through: :product_price_updates
    accepts_nested_attributes_for :product_price_updates, allow_destroy: true
end