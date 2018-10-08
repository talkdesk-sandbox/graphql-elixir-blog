defmodule Blog.Accounts.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Posts.Post
  alias Blog.Comments.Comment

  schema "authors" do
    has_many :posts, Post
    has_many :comments, Comment
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
