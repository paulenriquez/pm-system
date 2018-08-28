class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :validatable
        #  :timeoutable

  validates :username, uniqueness: true

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def is_admin?
    self.account_type == 'administrator'
  end
end
