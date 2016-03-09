require 'active_record'

class Membership < ActiveRecord::Base

  validates :user_id, presence: true
  validates :group_id, presence: true
  validates :pending, inclusion: { in: [true, false] }

end
