defmodule BlogWeb.Schema do
  use Absinthe.Schema
  import_types BlogWeb.Schema.Types

  alias BlogWeb.PostsResolver
  alias BlogWeb.AccountsResolver
  alias BlogWeb.CommentsResolver


  #I can have queries with args
  query do
    @desc "Get all posts"
    field :posts, non_null(list_of(non_null(:post))) do
      resolve &PostsResolver.all_posts/3
    end

    @desc "Get all authors"
    field :authors, non_null(list_of(non_null(:author))) do
      resolve &AccountsResolver.all_authors/3
    end

    @desc "Get all comments"
    field :comments, non_null(list_of(non_null(:comment))) do
      resolve &CommentsResolver.all_comments/3
    end

    @desc "Get a user of the blog"
    field :author, :author do
      arg :id, non_null(:id)
      resolve &AccountsResolver.find_author/3
    end
  end

  mutation do
    field :create_author, :author do
      arg :name, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &AccountsResolver.create_author/3
    end


  end

end
