require 'active_record'

class Membership < ActiveRecord::Base

  validates :user_name, presence: true
  validates :group_name, presence: true
  validates :pending, inclusion: { in: [true, false] }

end
