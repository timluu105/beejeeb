# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  helper_method :current_announcement, :admin_pages?, :cart_items_count,
    :current_notification

  def current_announcement
    @current_announcement ||= Announcement.enabled.random.first
  end

  def current_notification
    return unless current_user

    @current_notification ||= current_user.notifications.unread.random.first
  end

  def admin_pages?
    params[:controller].match /\Aadmin/
  end

  def cart_items_count
    @cart_items_count ||= current_user.cart_items.count
  end
end
