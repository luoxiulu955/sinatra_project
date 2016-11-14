require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'bcrypt'
require './student'

enable :sessions

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class Admin
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :passwordsalt, String
  property :passwordhash, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

helpers do
  
  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end

  def username
  	return session[:username]
  end
end

get "/login" do
  slim :login
end

get "/signup" do
  slim :signup
end

post "/signup" do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  
  user = Admin.new
  user.username = params[:username]
  user.passwordsalt = password_salt
  user.passwordhash = password_hash
  user.save
  
  session[:username] = params[:username]
  redirect "/students"
end

post "/login" do
  user = Admin.first(:username => params[:username])
  if user != nil
    if user.username == params[:username] && user.passwordhash == BCrypt::Engine.hash_secret(params[:password], user.passwordsalt)
      session[:username] = params[:username]
      redirect "/students"
    else
    	slim :error
    end
  else
  	slim :error
  end
end

get "/logout" do
  session[:username] = nil
  redirect "/login"
end