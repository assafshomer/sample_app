# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  email                 :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  password_digest       :string(255)
#  remember_token        :string(255)
#  admin                 :boolean          default(FALSE)
#  recieve_notifications :boolean          default(TRUE)
#  active                :boolean          default(FALSE)
#

class User < ActiveRecord::Base  
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :relationships,foreign_key: "follower_id",dependent: :destroy
  has_many :reversed_relationships, foreign_key: "followed_id",
                                      dependent: :destroy,
                                     class_name: "Relationship"
  has_many :followed_users,             through: :relationships,
                                         source: :followed
  has_many :followers,                  through: :reversed_relationships,
                                         source: :follower
  has_many :messages,               foreign_key: "sender_id",
                                      dependent: :destroy,
                                     class_name: "Message"
  has_many :recieved_messages,      foreign_key: "recipient_id", 
                                      dependent: :destroy, 
                                     class_name: "Message"                                     
  has_many :password_resets, dependent: :destroy  
  has_one :email_verification, dependent: :destroy                                   

	before_save { |user| user.email = email.downcase } 
  before_save :create_remember_token

  VALID_EMAIL_REGEX=/\A(\d|\w)(\d|\w|[.\-])*@((\d|\w)+\.)*(\d|\w)+\z/
  validates :name, 	    presence: true, 
  										    length: {maximum: 50}
  validates :email,     presence: true, 
  										    format: {with: VALID_EMAIL_REGEX}, 
  								    uniqueness: {case_sensitive: false}
  validates :password, length: { in: 6..20 }                  
  validates :password_confirmation, presence: true                          

  def feed
    # self.microposts
    # Micropost.from_users_followed_by(self)
    Micropost.smart_feed(self)
  end

  def mailbox
    Message.inbox(self)
  end

  def add_to_feed(micropost)
    self.feed << micropost unless self.feed.find_index(micropost)    
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

  # def self.search_name_and_email(search)
  #   if search
  #     find(:all, :conditions => ['name LIKE ? or email LIKE ?', "%#{search}%","%#{search}%" ])
  #   else
  #     find(:all)
  #   end
  # end

  # def self.search_one(term)
  #   no_spaces = term.split.join
  #   query="%#{no_spaces}%"
  #   sql='name LIKE ? or email LIKE ?'
  #   User.where([sql, query, query])
  # end

  # def self.search_many(terms)
  #   query = terms.split(',').map {|term| "%#{term}%" }
  #   sql='name LIKE ? or email LIKE ?'
  #   User.where([sql, query, query])
  # end

  private

    def create_remember_token
      begin
        self.remember_token = SecureRandom.urlsafe_base64          
      end while User.exists?(remember_token: self.remember_token)
    end

    # def create_remember_token
    #   generate_token(:remember_token)
    # end
end
