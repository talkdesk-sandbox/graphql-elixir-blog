defmodule BlogWeb.AccountsResolver do
  alias Blog.Accounts

  def all_authors(_root, _args, _info) do
    authors = Accounts.list_authors()
    {:ok, authors}
  end

  def create_author(_root, args, _info) do
    case Accounts.create_author(args) do
    {:ok, author} ->
      {:ok, author}
    _error ->
      {:error, "could not create author"}
    end
  end

  def find_author(_parent, %{id: id}, _resolution) do
   case Accounts.find_author(id) do
     nil ->
       {:error, "User ID #{id} not found"}
     user ->
       {:ok, user}
   end
 end

end
