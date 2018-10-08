defmodule BlogWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Blog.Repo
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  import Absinthe.Resolution.Helpers
  import_types Absinthe.Type.Custom

  object :author do
    field :id, :id
    field :email, :string
    field :name, :string
    field :password, :string
    field :posts, list_of(:post), resolve: dataloader(Blog.Posts)
    field :comments, list_of(:comment), resolve: dataloader(Blog.Comments)
  end

  object :post do
    field :content, :string
    field :created_at, :date
    field :title, :string
    field :author_id, :author, resolve: assoc(:author)
    field :comments, list_of(:comment), resolve: dataloader(Blog.Comments)
  end

  object :comment do
    field :content, :string
    field :created_at, :date
    field :author_id, :author, resolve: assoc(:author)
    field :post_id, :post, resolve: assoc(:post)
  end
end
