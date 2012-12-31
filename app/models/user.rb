class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email,:class_photo,:school,:class_name,:class_description,:syllabus, :password, :password_confirmation,:terms_of_service, :remember_me,:username,:avatar,:school_admin_id,:role,:bio,:state,:major,:website,:first_name,:last_name,:reset_password_token
  has_many :tweets, :dependent => :destroy, :order => "created_at DESC"
  has_many :reports, :dependent => :destroy, :order => "created_at DESC"
  attr_accessor :school
  
  has_attached_file :avatar,
    :whiny => false,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "uploaded_files/profile/:id/:style/:basename.:extension",
    :bucket => "edupost",
    :styles => {
    :original => "900x900>",
    :default => "280x190>",
    :other => "96x96>" } if Rails.env == 'production'
  has_attached_file :avatar,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == 'development'

  has_attached_file :class_photo,
    :whiny => false,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "uploaded_files/profile/:id/:style/:basename.:extension",
    :bucket => "edupost",
    :styles => {
    :original => "900x900>",
    :default => "280x190>",
    :other => "96x96>" } if Rails.env == 'production'
  has_attached_file :class_photo,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == 'development'
  validates :first_name,:last_name,:presence => true
  validates :username,:uniqueness => true,:presence => true,:format => {:with => /^[\w\-@]*$/ , :message => "Only use letters, numbers with no spaces"}, :on => :update
  belongs_to :school_admin
  has_many :sent_follows, :class_name => "Follow", :foreign_key => :user_id, :dependent => :destroy
  has_many :received_follows, :class_name => 'Follow', :foreign_key => :receiver_id,:dependent => :destroy
  has_many :favorites, :dependent => :destroy
  validate :email_should_not_exist_in_school_admin,:email_should_not_exist_in_admin
  validates_acceptance_of :terms_of_service, :message => "In order to use the service, You must first agree to the terms and conditions", :on => :update

  def email_should_not_exist_in_school_admin
    student = SchoolAdmin.find_by_email(self.email)
    return true unless student.present?
    self.errors.add(:email, "is already taken.")
    return false
  end

  def email_should_not_exist_in_admin
    student = Admin.find_by_email(self.email)
    return true unless student.present?
    self.errors.add(:email, "is already taken")
    return false
  end

  def generate_password_reset_code
    self.reset_password_token = Digest::SHA2.hexdigest(Time.now.to_s)
    self.reset_password_sent_at = Time.now
    save
  end

  def favorite_for(tweet)
    self.favorites.find_by_tweet_id(tweet)
  end

  def fullname
    self.first_name+' '+self.last_name
  end
end
