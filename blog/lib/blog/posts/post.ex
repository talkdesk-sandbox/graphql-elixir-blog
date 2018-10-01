defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts.Author
  alias Blog.Comments.Comment

  schema "posts" do
    belongs_to :author, Author
    has_many :comments, Comment
    field :content, :string
    field :created_at, :date
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :created_at, :author_id])
    |> validate_required([:title, :content, :created_at, :author_id])
  end
end
