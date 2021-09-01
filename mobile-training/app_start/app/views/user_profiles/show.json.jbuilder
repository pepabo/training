json.extract! @user, :id, :name

json.gravatar_url @user.gravatar_url(**{ size: 50 })
json.microposts_count @user.microposts.count
json.following_count @user.following.count
json.followers_count @user.followers.count
json.is_current_user current_user?(@user)

json.microposts @microposts do |micropost|
  json.extract! micropost, :id, :content
  json.image_url url_for(micropost.display_image) if micropost.image.attached?
  json.created_at_time_ago_in_words time_ago_in_words(micropost.created_at)
end
