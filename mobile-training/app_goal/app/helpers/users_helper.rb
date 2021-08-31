module UsersHelper

  # 渡されたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 })
    size = options[:size]
    image_tag(user.gravatar_url(**{ size: size }), alt: user.name, class: "gravatar")
  end
end