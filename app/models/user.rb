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
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      false
    end
  end

  # returns all the group IDs the user joins
  def _group_names
    Membership.where(user_name: self.name, pending: false).map { |m| m.group_name }
  end

  # returns all the groups the user joins
  def groups
    Group.where(name: self._group_names)
  end

  # returns all the wishes assigned to the user
  def wishes
    Wish.where(group_name: self._group_names)
  end

  # returns non-nil iff the user owns the group
  def owner_of?(group_name)
    group = Group.find_by(name: group_name)
    group && group.owner_name == self.name
  end

  # returns one of :member :pending or false
  def join_state(group_name)
    membership = Membership.find_by(user_name: self.name, group_name: group_name)
    if !membership
      false
    elsif membership.pending
      :pending
    else
      :member
    end
  end

end
