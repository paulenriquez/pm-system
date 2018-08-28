class ProductPriceUpdate < ApplicationRecord
    belongs_to :price_update
    belongs_to :product
end
