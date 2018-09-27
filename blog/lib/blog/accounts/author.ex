defmodule Blog.Accounts.Author do
  use Ecto.Schema
  import Ecto.Changeset


  schema "authors" do
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
