class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true

  enumerate :status

  store_accessor :content, :text, :url, :route, :params
end
