class User < ApplicationRecord
  extend Enumerize # for role support

  has_many :page_contents

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :trackable,
          :validatable,
          :omniauthable,
          :omniauth_providers => [:facebook]

  enumerize :role, in: [ :admin, :publisher, :editor, :user ], default: :user



  # Validations
  validates_presence_of :password, :allow_blank => true, on: :update
  validates_presence_of  :password_confirmation, presence: true, :allow_blank => true, on: :update

  # Get role type
  def role_type
    return self.role.to_s
  end

  # Check if admin
  def is_admin?
    #self.role == 'admin'
    ['admin','publisher','editor'].include? self.role
  end

  # Omniauth via Facebook capability
  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.age_range = auth.extra.raw_info.age_range.min[1]
      user.image = auth.info.image
      user.gender = auth.extra.raw_info.gender if user.gender.blank?
      user.role = 'user'
      #user.birthday = auth.extra.raw_info.birthday
      # If you are using confirmable and the provider(s) you use validate emails, uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end      
  end

  # Facebook Profile link
  def profile_link
    if self.uid
      return "https://facebook.com/#{self.uid}"
    else
      return false
    end
  end

  private    

  # If a user is going to be updated the password isn't needed
  def password_required?
    new_record? ? super : false
  end  

end
