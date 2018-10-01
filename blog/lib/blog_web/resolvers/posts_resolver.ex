defmodule BlogWeb.PostsResolver do
  alias Blog.Posts

  def all_posts(_root, _args, _info) do
    posts = Posts.list_posts()
    {:ok, posts}
  end

end
