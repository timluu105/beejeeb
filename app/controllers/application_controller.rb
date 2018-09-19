# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  helper_method :enabled_announcement, :admin_pages?

  def enabled_announcement
    @enabled_announcement ||= Announcement.enabled.last
  end

  def admin_pages?
    params[:controller].match /\Aadmin/
  end
end
