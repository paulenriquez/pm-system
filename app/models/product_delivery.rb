class ProductDelivery < ApplicationRecord
    belongs_to :product
    belongs_to :delivery
    belongs_to :tank, optional: true
end