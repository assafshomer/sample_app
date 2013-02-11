# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :relationships,          foreign_key: "follower_id",                                  dependent: :destroy
  has_many :reversed_relationships, foreign_key: "followed_id",                                  dependent: :destroy,                                 class_name: "Relationship"
  has_many :followed_users,             through: :relationships,                                     source: :followed
  has_many :followers,                  through: :reversed_relationships,                                     source: :follower

	before_save { |user| user.email = email.downcase } 
  before_save :create_remember_token

  VALID_EMAIL_REGEX=/^(\d|\w)(\d|\w|[.\-])*@((\d|\w)+\.)*(\d|\w)+$/
  validates :name, 	    presence: true, 
  										    length: {maximum: 50}
  validates :email,     presence: true, 
  										    format: {with: VALID_EMAIL_REGEX}, 
  								    uniqueness: {case_sensitive: false}
  validates :password,  presence: true, 
                          length: { in: 6..20 }                  
  validates :password_confirmation, presence: true                          

  def feed
    # self.microposts
    Micropost.where('user_id=?', id)
  end

  def follow!(user)
    self.relationships.create!(followed_id: user.id)
  end

  def following?(user)
    !!self.relationships.find_by_followed_id(user)    
  end

  def unfollow!(user)
    self.relationships.find_by_followed_id(user).destroy
  end

  def followed?(user)
    self.reversed_relationships.find_by_follower_id(user)
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64      
    end
end
