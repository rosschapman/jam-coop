# frozen_string_literal: true

class InvitationsController < ApplicationController
  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.create_with(user_params).find_or_initialize_by(email: params[:email])
    authorize @user

    if @user.save
      artist = Artist.find_by(id: params[:artist_id])
      @user.artists << artist if artist

      send_invitation_instructions
      redirect_to root_path, notice: "An invitation email has been sent to #{@user.email}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email).merge(password: SecureRandom.base58, verified: true)
  end

  def send_invitation_instructions
    UserMailer.with(user: @user).invitation_instructions.deliver_later
  end
end