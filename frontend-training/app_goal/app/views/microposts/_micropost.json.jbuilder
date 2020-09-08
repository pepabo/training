json.extract! micropost, :id, :content

json.picture_url micropost.picture.url if micropost.picture?

json.created_at_time_ago_in_words time_ago_in_words(micropost.created_at)

json.user do
  json.extract! micropost.user, :id, :name
  json.gravatar_url micropost.user.gravatar_url(size: 50)
  json.is_current_user current_user?(micropost.user)
end
