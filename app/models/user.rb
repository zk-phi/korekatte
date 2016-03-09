require 'active_record'
require_relative 'group'
require_relative 'membership'

class User < ActiveRecord::Base

  username_re = /\A[a-z0-9_]+\Z/i
  mail_addr_re = /(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i
  validates :name, presence: true, uniqueness: true, format: { with: username_re }
  validates :email, presence: true, uniqueness: true, format: { with: mail_addr_re }
  validates :password_hash, presence: true, confirmation: true
  validates :password_salt, presence: true

  # returns an User object on success, false otherwise.
  def self.authenticate(name, password)
    user = self.find_by(name: name)
    user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) && user
  end

  # returns all the group IDs the user joins
  def _group_ids
    Membership.where(user_id: self.id, pending: false).map! { |m| m.group_id }
  end

  # returns all the groups the user joins
  def groups
    Group.where(id: self._group_ids)
  end

  # returns all the wishes assigned to the user
  def wishes
    Wish.where(group_id: self._group_ids)
  end

  # returns non-nil iff the user owns the group
  def owner_of?(group_id)
    group = Group.find(group_id)
    group && group.owner_id == self.id
  end

  # returns one of :member :pending or false
  def join_state(group_id)
    membership = Membership.find_by(user_id: self.id, group_id: group_id)
    if !membership
      false
    elsif membership.pending
      :pending
    else
      :member
    end
  end

end
