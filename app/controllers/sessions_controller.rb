# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'admin'

  def new
    redirect_to admin_root_path if admin_logged_in?
  end

  def create
    admin = AdminUser.find_by(email: params[:email])

    if admin.nil?
      flash.now[:alert] = 'Email hoặc mật khẩu không đúng.'
      render :new, status: :unprocessable_entity
      return
    end

    begin
      if admin.authenticate(params[:password])
        session[:admin_id] = admin.id
        flash[:notice] = 'Đăng nhập thành công!'
        redirect_to admin_root_path
      else
        flash.now[:alert] = 'Email hoặc mật khẩu không đúng.'
        render :new, status: :unprocessable_entity
      end
    rescue BCrypt::Errors::InvalidHash => e
      Rails.logger.error("Invalid password hash for admin: #{admin.email}. Error: #{e.message}")
      flash.now[:alert] = 'Lỗi hệ thống. Vui lòng liên hệ quản trị viên.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:admin_id)
    flash[:notice] = 'Đã đăng xuất.'
    redirect_to root_path
  end
end
