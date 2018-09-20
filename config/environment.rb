# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

require "#{Rails.root}/lib/config"

APP_CONFIG = Config.get('app_config')

# Initialize the Rails application.
Rails.application.initialize!
