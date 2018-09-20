class ApplicationMailer < ActionMailer::Base
  default from: "#{APP_CONFIG['title']}<#{APP_CONFIG['from_email']}"
  append_view_path Rails.root.join('app', 'views', 'mailers')
  layout 'mailer'
end
