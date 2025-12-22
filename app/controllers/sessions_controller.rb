# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'admin'

  def new
    redirect_to admin_root_path if admin_logged_in?
  end

  def create
    admin = AdminUser.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      flash[:notice] = 'Đăng nhập thành công!'
      redirect_to admin_root_path
    else
      flash.now[:alert] = 'Email hoặc mật khẩu không đúng.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:admin_id)
    flash[:notice] = 'Đã đăng xuất.'
    redirect_to root_path
  end
end
