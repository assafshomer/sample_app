module SessionsHelper
	
	def sign_in(user, remember_me = true)
		if remember_me 
			cookies.permanent[:remember_token]=user.remember_token
		else
			cookies[:remember_token]=user.remember_token
		end
		self.current_user=user 		
	end

	def signed_in?
		!current_user.nil?
	end

	def current_user=(user)
		@current_user=user
	end

	def current_user
		@current_user ||=User.find_by_remember_token(cookies[:remember_token])		
	end

	def current_user?(user)
		user==current_user		
	end

	def sign_out
		self.current_user=nil # I don't think this is necessary
		cookies.delete(:remember_token)		
	end

	def authenticate
    deny_access unless signed_in?    
  end

	def deny_access		
		store_location
		redirect_to signin_path, notice: "Please sign in."		
	end

	def store_location
		session[:return_to]=request.fullpath
	end

	def clear_stored_location
		session[:return_to]=nil
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)				
		clear_stored_location
	end

	def need_to_sign_out_first
		(redirect_to root_path, notice: "Please sign out first") if signed_in?
	end

end
