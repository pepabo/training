json.extract! current_user, :id, :name

json.gravatar_url current_user.gravatar_url(**{ size: 50 })
json.microposts_count current_user.microposts.count
json.following_count current_user.following.count
json.followers_count current_user.followers.count
