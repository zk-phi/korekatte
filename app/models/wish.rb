require 'active_record'

class Wish < ActiveRecord::Base

  validates :text, presence: true
  validates :group_id, presence: true
  validates :user_id, presence: true
  validates :active, inclusion: { in: [false, true] }

end
