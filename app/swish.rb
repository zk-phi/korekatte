require 'sinatra/base'
require 'sinatra/activerecord'
require 'bcrypt'
require_relative 'db'
# require_relative 'mail'
require_relative 'models/user'
require_relative 'models/group'
require_relative 'models/membership'
require_relative 'models/wish'

class Swish < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  configure do
    set :public_folder, "#{root}/../public"
    DB.connect(ENV['RACK_ENV'])
  end

  helpers do                    # helper functions for the views
    def e(str)
      Rack::Utils.escape_html(str)
    end
  end

  # ----- root

  get '/' do
    if session[:user]
      redirect '/wishes'
    else
      redirect '/log_in'
    end
  end

  # ----- user

  get '/sign_up' do
    if session[:user]
      redirect '/'
    else
      erb :sign_up
    end
  end

  post '/sign_up' do
    if params[:password] == ""
      @error_msgs = [ "Password is empty." ]
      erb :sign_up
    elsif params[:password] != params[:confirm_password]
      @error_msgs = [ "Confirm Password does not match." ]
      erb :sign_up
    else
      begin
        salt = BCrypt::Engine.generate_salt
        session[:user] = User.create!(
          name: params[:name],
          email: params[:email],
          password_salt: salt,
          password_hash: BCrypt::Engine.hash_secret(params[:password], salt)
        )
        redirect '/'
      rescue ActiveRecord::RecordInvalid => e
        @error_msgs = e.record.errors.full_messages
        erb :sign_up
      end
    end
  end

  get '/log_in' do
    if session[:user]
      redirect '/'
    else
      erb :log_in
    end
  end

  post '/log_in' do
    user = User.authenticate(params[:name], params[:password])
    if user
      session[:user] = user
      redirect '/'
    else
      @error_msgs = [ "Authentication failed." ]
      erb :log_in
    end
  end

  get '/log_out' do
    session.clear
    redirect '/'
  end

  get '/user' do
    unless session[:user]
      redirect '/'
    else
      erb :user
    end
  end

  post '/user/lookup' do
    group = Group.find_by(name: params[:name])
    if group
      redirect "/group/#{group.name}"
    else
      @error_msgs = [ "No groups found." ]
      erb :user
    end
  end

  post '/user/organize' do
    begin
      group = Group.create!(name: params[:name], owner_name: session[:user].name)
      Membership.create(user_name: session[:user].name, group_name: group.name, pending: false)
      redirect "/user"
    rescue ActiveRecord::RecordInvalid => e
      @error_msgs = e.record.errors.full_messages
      erb :user
    end
  end

  # ----- group

  get '/group/:group_name' do
    unless session[:user]
      redirect '/'
    else
      @group = Group.find_by(name: params[:group_name])
      membership = session[:user].join_state(params[:group_name])
      if membership == :member
        erb :group_details
      elsif membership == :pending
        erb :group_pending
      else
        erb :group_join
      end
    end
  end

  post '/group/join' do
    unless session[:user].join_state(params[:group_name])
      Membership.create(user_name: session[:user].name, group_name: params[:group_name], pending: true)
    end
    redirect "/group/#{params[:group_name]}"
  end

  # post '/group/remove_member' do
  #   membership = Membership.find(params[:membership_id])
  #   if session[:user].owner_of?(membership.group_name)
  #     membership.destroy
  #   end
  #   redirect "/group/#{params[:group_name]}"
  # end

  post '/group/accept_request' do
    request = Membership.find(params[:request_id])
    if session[:user].owner_of?(request.group_name)
      request.update(pending: false)
    end
    redirect "/group/#{request.group_name}"
  end

  post '/group/reject_request' do
    request = Membership.find(params[:request_id])
    if session[:user].owner_of?(request.group_name)
      request.destroy
    end
    redirect "/group/#{request.group_name}"
  end

  # ----- wish

  get '/wishes' do
    unless session[:user]
      redirect '/'
    else
      @wishes = session[:user].wishes
      @groups = session[:user].groups
      erb :wishes
    end
  end

  post '/wishes/new' do
    if session[:user].join_state(params[:group_name]) == :member
      begin
        Wish.create(
          text: params[:text],
          group_name: params[:group_name],
          user_name: session[:user].name,
          active: true,
          deactivated_by: nil
        )
        redirect '/wishes'
      rescue ActiveRecord::RecordInvalid => e
        @error_msgs = e.record.errors.full_messages
        erb :wishes
      end
    end
  end

  post '/wishes/complete' do
    wish = Wish.find(params[:wish_id])
    if session[:user].join_state(wish.group_name) == :member
      wish.update(active: false, deactivated_by: session[:user].name)
    end
    redirect "/wishes"
  end

  post '/wishes/activate' do
    wish = Wish.find(params[:wish_id])
    if !wish.active && session[:user].join_state(wish.group_name) == :member
      wish.update(active: true)
    end
    redirect "/wishes"
  end

  post '/wishes/destroy' do
    wish = Wish.find(params[:wish_id])
    if wish.user_name == session[:user].name
      wish.destroy
    end
    redirect "/wishes"
  end

end
