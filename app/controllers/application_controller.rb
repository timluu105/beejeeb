# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  helper_method :enabled_announcement

  def enabled_announcement
    @enabled_announcement ||= Announcement.enabled.last
  end
end
