class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :added_by, through: :movements
  has_many :receivers, through: :movements
  has_many :shareholders, :dependent => :destroy, :foreign_key => 'user_id'
  has_many :contacts, :dependent => :destroy, :foreign_key => 'user_id'
  has_many :contacted, :dependent => :destroy, :class_name => 'Contact', :foreign_key => 'contact_id'
  has_many :movements, :dependent => :destroy, :foreign_key => 'added_by_id'
  has_and_belongs_to_many :groups


  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil, invitation_token=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

    # Registered and also with that facebook credentials
    if user
      user.avatar = auth.info.image
      user.save
      return user
    else
      # Registered with no facebook credentials
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        registered_user.name = auth.extra.raw_info.name
        registered_user.uid = auth[:uid]
        registered_user.provider = auth[:provider]
        registered_user.avatar = auth.info.image
        registered_user.save!
        return registered_user

      # Not registered or registered by someone else via invitable with a different email
      else
        # No user apparently, but he could be registering with a different email he was invited to
        # Lets find out if he was invited
        invited_user = User.find_by(:invitation_token => Devise.token_generator.digest(:self, :invitation_token, invitation_token)) if invitation_token

        # If he was, update user, dont create a new one
        if invited_user
          invited_user.provider = auth.provider
          invited_user.email = auth.info.email
          invited_user.name = auth.extra.raw_info.name
          invited_user.uid = auth.uid
          invited_user.avatar = auth.info.image
          invited_user.save!
          return registered_user
        else
          user = User.create(name: auth.extra.raw_info.name,
                             provider: auth.provider,
                             avatar: auth.info.image,
                             uid: auth.uid,
                             email: auth.info.email,
                             password: Devise.friendly_token[0,20],
                             # oauth_token:auth.credentials.token
                            )
        end
      end
    end
  end


  def self.find_for_google_oauth2(access_token, signed_in_resource=nil, invitation_token=nil)
      data = access_token.info
      user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first

      # Registered and also with that google credentials
      if user
        user.avatar = data["image"]
        user.save
        return user
      else
        # Registered with no google credentials
        registered_user = User.where(:email => access_token.info.email).first
        if registered_user
          registered_user.name = data["name"]
          registered_user.avatar = data["image"]
          registered_user.uid = access_token.uid
          registered_user.provider = access_token.provider
          registered_user.save!
          return registered_user
        # Not registered or registered by someone else via invitable with a different email
        else
          # No user apparently, but he could be registering with a different email he was invited to
          # Lets find out if he was invited
          invited_user = User.find_by(:invitation_token => Devise.token_generator.digest(:self, :invitation_token, invitation_token)) if invitation_token

          # If he was, update user, dont create a new one
          if invited_user
            invited_user.provider = access_token.provider
            invited_user.email = data["email"]
            invited_user.avatar = data["image"]
            invited_user.name = data["name"]
            invited_user.uid = access_token.uid
            invited_user.save!
            return invited_user
          else
            user = User.create(
              name: data["name"],
              provider: access_token.provider,
              avatar: data["image"],
              email: data["email"],
              uid: access_token.uid,
              password: Devise.friendly_token[0,20],
            )
          end
        end
     end
  end


  # def self.find_for_twitter_oauth(auth, signed_in_resource=nil, invitation_token=nil)
  #   user = User.where(:provider => auth.provider, :uid => auth.uid).first

  #   # Registered and also with that twitter credentials
  #   if user
  #     return user
  #   else
  #     registered_user = User.where(:email => auth.uid + "@twitter.com").first
  #     if registered_user
  #       registered_user.name = auth.info.name
  #       registered_user.save!
  #       return registered_user
  #     # Not registered or registered by someone else via invitable with a different email
  #     else
  #       # No user apparently, but he could be registering with a different email he was invited to
  #       # Lets find out if he was invited
  #       invited_user = User.find_by(:invitation_token => Devise.token_generator.digest(:self, :invitation_token, invitation_token))

  #       # If he was, update user, dont create a new one
  #       if invited_user
  #         invited_user.provider = auth.provider
  #         invited_user.email = auth.uid + "@twitter.com"
  #         invited_user.name = auth.info.name
  #         invited_user.uid = auth.uid
  #         invited_user.save!
  #         return invited_user
  #       else
  #         user = User.create(
  #           name: auth.info.name,
  #           provider: auth.provider,
  #           uid: auth.uid,
  #           email: auth.uid+"@twitter.com",
  #           password: Devise.friendly_token[0,20],
  #         )
  #       end
  #     end
  #   end
  # end

  
end
