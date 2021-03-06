require 'active_record'

class Wish < ActiveRecord::Base

  validates :text, presence: true
  validates :group_name, presence: true
  validates :user_name, presence: true
  validates :active, inclusion: { in: [false, true] }

end
