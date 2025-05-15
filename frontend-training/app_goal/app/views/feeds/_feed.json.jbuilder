# extract! は feed 変数の id, content アトリビュートがそれぞれの名前で設定される
json.extract! feed, :id, :content

# feed に画像があれば、 picture_url という要素に URL を設定する
json.image_url url_for(feed.display_image) if feed.image.attached?

# Helper に定義したメソッドも使うことができる
json.created_at_time_ago_in_words time_ago_in_words(feed.created_at)

# ネストした要素を定義したいときは do を使う
json.user do
  json.extract! feed.user, :id, :name
  json.gravatar_url feed.user.gravatar_url(**{ size: 50 })
  json.is_current_user current_user?(feed.user)
end
