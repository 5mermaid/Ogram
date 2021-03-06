class Content < ApplicationRecord
  has_many :comments, dependent: :destroy

  belongs_to :user
  has_one_attached :file
  geocoded_by :place
  has_many :user_views
  validates :description, length: { minimum: 1 }
  after_validation :geocode, if: :will_save_change_to_place?

  def downvoted?(user)
    number_of_user_views = self.user_views.count #20
    number_of_user_views_downvoted = self.user_views.where(downvoted: true).count #10
    if number_of_user_views > 0
      ratio = number_of_user_views_downvoted / number_of_user_views
      return false if number_of_user_views >= 2 && ratio >= 0.5
    end

    user.user_views.select(&:downvoted).map(&:content).include?(self)
  end

  def saved?(user)
    user.user_views.select(&:saved).map(&:content).include?(self)
  end
end
