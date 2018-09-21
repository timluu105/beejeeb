class Announcement < ApplicationRecord
  validates :title, presence: true

  enumerate :status
end
