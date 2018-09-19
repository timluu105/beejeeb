class Announcement < ApplicationRecord
  STATUSES = %w[enabled disabled]

  validates :title, :status, presence: true
  before_validation :set_status

  enum status: STATUSES.each_with_object({}){ |s, h| h[s] = s }

  private

  def set_status
    return if status.present?

    self.status = STATUSES.first
  end
end
