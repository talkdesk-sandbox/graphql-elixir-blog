defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  forward "/graphiql",
    Absinthe.Plug.GraphiQL,
    schema: BlogWeb.Schema
  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end

  forward("/graphql",
    Absinthe.Plug,
    schema: BlogWeb.Schema)

end
