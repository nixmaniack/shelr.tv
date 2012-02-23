class UsersController < ApplicationController

  respond_to :html, :json, :atom

  before_filter :login_required, except: [:show, :login, :authenticate, :index]

  def index
    @users = User.desc(:created_at).page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.atom do
        @records = Record.desc(:created_at).page(params[:page]).limit(25)
        respond_with @records
      end
      format.html do
        @records = @user.records.page(params[:page]).per(5)
        respond_with @user
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.editable_by?(current_user)
      flash[:notice] = "Updated!"
      @user.update_attributes(params[:user])
    else
      flash[:error] = "Heh. No Way, man :)"
    end
    redirect_to @user
  end


  #
  # Session management
  #

  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

  def login
    redirect_to '/auth/github'
  end

  def authenticate
    provider = params[:provider]
    uid_field = "#{provider}_uid"
    name_field = "#{provider}_name"
    omniauth = request.env["omniauth.auth"]
    user = User.where(uid_field => omniauth['uid']).first

    if user
      flash[:notice] = "Signed in successfully."
      session[:user_id] = user.id.to_s
      redirect_to user_path(user)
    else
      user_info = omniauth['info']
      user = User.new(nickname: user_info['nickname'])
      user.update_attribute(uid_field, omniauth['uid'])
      user.update_attribute(name_field, user_info['nickname'])
      user.update_attribute('about', user_info['description'])
      user.update_attribute('website', user_info['urls'].try(:values).try(:last))

      if user.save
        session[:user_id] = user.id.to_s
        flash[:notice] = "Signed in successfully."
        redirect_to edit_user_path(user)
      else
        binding.pry
        flash[:notice] = "Failed"
        redirect_to root_url
      end
    end
  end
end
