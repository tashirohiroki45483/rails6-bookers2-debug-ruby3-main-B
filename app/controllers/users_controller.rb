class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:update, :edit]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new
    @posts_today_count = posts_today_count(@user)
    @posts_yesterday_count = posts_yesterday_count(@user)
    @posts_difference = posts_difference(@user)
    @posts_this_week_count = posts_this_week_count(@user)
    @posts_last_week_count = posts_last_week_count(@user)
    @posts_week_difference = posts_week_difference(@user)
  end

  def index
    @users = User.all
    @book = Book.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end

  def posts_today_count(user)
    user.books.where('created_at >= ?', Time.zone.now.beginning_of_day).count
  end

  def posts_yesterday_count(user)
    user.books.where(created_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).count
  end

  def posts_difference(user)
    today_count = posts_today_count(user)
    yesterday_count = posts_yesterday_count(user)
    if yesterday_count.zero?
      return 0 if today_count.zero?
      return 100
    end
    ((today_count.to_f / yesterday_count) * 100).round(2)
  end

  def posts_this_week_count(user)
    user.books.where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week).count
  end

  def posts_last_week_count(user)
    user.books.where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).count
  end

  def posts_week_difference(user)
    this_week_count = posts_this_week_count(user)
    last_week_count = posts_last_week_count(user)
    if last_week_count.zero?
      return 0 if this_week_count.zero?
      return 100
    end
    ((this_week_count.to_f / last_week_count) * 100).round(2)
  end

end