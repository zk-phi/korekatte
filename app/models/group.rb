require 'active_record'
require_relative 'membership'

class Group < ActiveRecord::Base

  groupname_re = /\A[a-z0-9_]+\Z/i
  validates :name, presence: true, uniqueness: true, format: { with: groupname_re }
  validates :owner_name, presence: true

  # returns all accepted memberships of the group as an array
  def memberships
    Membership.where(group_name: self.name, pending: false)
  end

  # returns all the requests to the group as an array
  def requests
    Membership.where(group_name: self.name, pending: true)
  end

end
