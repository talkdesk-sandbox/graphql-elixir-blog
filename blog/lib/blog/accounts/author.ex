defmodule Blog.Accounts.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Posts.Post
  alias Blog.Comments.Comment

  schema "authors" do
    has_many :posts, Post, foreign_key: :post_id
    has_many :comments, Comment, foreign_key: :comment_id
    field :email, :string
    field :name, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
  end
end
