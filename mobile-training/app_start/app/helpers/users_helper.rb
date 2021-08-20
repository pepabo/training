module UsersHelper
  # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user, size: 80)
    image_tag(user.gravatar_url(size: size), alt: user.name, class: "gravatar")
  end
end
