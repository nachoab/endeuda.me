class API::ContactsController < Api::ApiController

  def index
    render :json => current_user.contacts
  end

  def create
    contacts = []
    contacts_array_params.each do |key, value|
      email = value[:email]

      if email 
        @user = User.find_by_email(email)

        if @user != current_user
          if !@user
            @user = User.invite!({ :email => email, :name => email[/[^@]+/]  }, current_user)
            Contact.create(:user => @user, :contact => current_user)
          end
          contacts.push Contact.create(:user => current_user, :contact => @user )
        end
      end
    end
    render :json => contacts
  end

  def check_registered
    users = User.where(:email => params[:contact][:emails])
    render :json => users
  end

private

  def contacts_array_params
    params.permit(contact: [:user_id, :email, :name])[:contact]
  end

  def contacts_params
    params.require(:contact).permit(:user_id, :email)
  end

end
