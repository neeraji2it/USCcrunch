class PostsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @post = @user.tweets.new
    render :layout => false
  end

  def create
    @user = User.find(params[:user_id])
    @post = @user.tweets.new(params[:tweet])
    @post.user_id = current_user.id
    @post.receiver_id = @user.id
    if @post.save
      render :update do |page|
        flash[:notice] = "Successfully twitted this user."
        page.redirect_to profiles_path
      end
    else
      if remotipart_submitted?
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def repost
    @post = Tweet.find(params[:user_id])
    @repost = Tweet.new(:user_id => @post.user_id, :receiver_id => @post.receiver_id, :body => @post.body)
    if @repost.save
      render :update do |page|
        flash[:notice] = "Successfully Reposted."
        page.reload
      end
    else
      render :update do |page|
        flash[:error] = "Failed to Repost."
        page.reload
      end
    end
  end

  def reply
    @post = Tweet.find(params[:id])
    render :layout => false
  end

  def reply_post
    @post = Tweet.find(params[:user_id])
    @repost = Tweet.new(params[:tweet])
    @repost.user_id = current_user.id
    @repost.receiver_id = @post.receiver_id
    @repost.tweet_id = @post.id
    @repost.reply = true
    if @repost.save
      render :update do |page|
        flash[:notice] = "Successfully Replied."
        page.reload
      end
    else
      if remotipart_submitted?
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def show

  end

  def favourite
    @post = Tweet.find(params[:user_id])
    @favourite = Favorite.new(:user_id => current_user.id,:tweet_id=>@post.id,:status => true).save
    render :update do |page|
      page.alert('Marked as Favourites')
      page.reload
    end
  end

  def update_favourite
    @post = Tweet.find(params[:user_id])
    @favourite = @post.favorite.update_attribute(:status, false)
    render :update do |page|
      page.alert('Unmarked as Favourites')
      page.reload
    end
  end

  def update_mark_favourite
    @post = Tweet.find(params[:user_id])
    @favourite = @post.favorite.update_attribute(:status, true)
    render :update do |page|
      page.alert('marked as Favourites')
      page.reload
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @post = @user.tweets.find(params[:id])
    if @post.destroy
      respond_to do |format|
        format.js{@post}
      end
    end
  end
end