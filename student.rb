require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require './login'

configure :development, :test do
  DataMapper.setup(:default,
  "sqlite3://#{Dir.pwd}/development.db")
  end
  
configure :production do
  DataMapper.setup(:default,
  ENV['DATABASE_URL'])
end

class Student
  include DataMapper::Resource
  property :id, Serial
  property :studentid, Integer
  property :lastname, String
  property :firstname, String
  property :address, Text
  property :city, String
  property :zipcode, Integer
  property :phonenumber, Integer
  property :emailaddress, String
end

DataMapper.finalize

get '/students' do
  if login?
    @students = Student.all
    slim :students
  else
    redirect to('/login')
  end
end

get '/students/new' do
  halt(401, 'NOT Authorized') unless login?
  @student = Student.new
  slim :new_student
end

get '/students/:id' do
  @student = Student.get(params[:id])
  slim :show_student
end

get '/students/:id/edit' do
  halt(401, 'NOT Authorized') unless login?
  @student = Student.get(params[:id])
  slim :edit_student
end

post '/students' do  
  student = Student.create(params[:student])
  redirect to("/students/#{student.id}")
end

put '/students/:id' do
  halt(401, 'NOT Authorized') unless login?
  student = Student.get(params[:id])
  student.update(params[:student])
  redirect to("/students/#{student.id}")
end

delete '/students/:id' do
  halt(401, 'NOT Authorized') unless login?
  Student.get(params[:id]).destroy
  redirect to('/students')
end
