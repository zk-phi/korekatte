require 'active_record'
require_relative 'membership'

class Group < ActiveRecord::Base

  groupname_re = /\A[a-z0-9_]+\Z/i
  validates :name, presence: true, uniqueness: true, format: { with: groupname_re }
  validates :owner_id, presence: true

  # returns all the users in the group as an array
  def members
    ids = Membership.where(group_id: self.id, pending: false).map { |m| m.user_id }
    User.where(id: ids)
  end

  # returns all the requests to the group as an array
  def requests
    Membership.where(group_id: self.id, pending: true)
  end

end
