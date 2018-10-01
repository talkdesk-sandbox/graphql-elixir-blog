defmodule BlogWeb.CommentsResolver do
  alias Blog.Comments

  def all_comments(_root, _args, _info) do
    comments = Comments.list_comments()
    {:ok, comments}
  end

end
