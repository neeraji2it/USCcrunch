class SchoolSessionsController < Devise::SessionsController
  def new
  end

  def create
    resource = warden.authenticate!(:scope => resource_name)
    render :update do |page|
      page.redirect_to school_path(current_school_admin)
    end
  end

  def destroy
    signed_in = signed_in?(resource_name)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    flash[:notice] = "Logout Sucessfully."
    redirect_to "/"
  end
end