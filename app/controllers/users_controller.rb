class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
  end

  def destroy
    @user = current_user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

end