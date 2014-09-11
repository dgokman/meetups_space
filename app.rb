require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @meetup_all = Meetup.order(:name)
  erb :index
end

post '/' do
  @meetup_all = []
  if /./ !~ params[:name] || /./ !~ params[:description] || /./ !~ params[:location]
    @error = 'Entries cannot be blank'
    erb :index
  else

    new_meetup = Meetup.create(name: params[:name],
    description: params[:description], location: params[:location])
    new_meetup.save
    flash[:notice] = "You've created a new group!"
    #binding.pry
    redirect "/meetups/#{new_meetup.id}"
  end
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

get '/meetups/:id' do
  @user = User.all
  @membership = Membership.all
  @meetup = Meetup.find(params[:id])
  #binding.pry
  erb :show
end

post '/meetups/:meetup_id/memberships' do

  meetup = Meetup.find(params[:meetup_id])
  @membership = Membership.new(user_id: current_user.id, meetup_id: meetup.id)
  if @membership.save
    flash[:notice] = "You've joined the meetup!"
    redirect "/meetups/#{meetup.id}"
  else
    flash[:notice] = "error: already signed up"
    redirect "/meetups/#{meetup.id}"
  end
end

post '/meetups/:meetup_id/leave' do

  meetup = Meetup.find(params[:meetup_id])
  @membership = Membership.delete_all(user_id: current_user.id, meetup_id: meetup.id)
    flash[:notice] = "You've left this meetup!"
    redirect "/meetups/#{meetup.id}"

end

