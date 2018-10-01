defmodule Absinthe.Schema do
  import Absinthe.Schema.Notation

  @moduledoc """
  Define a GraphQL schema.

  See also `Absinthe.Schema.Notation` for a reference of the macros imported by
  this module available to build types for your schema.

  ## Basic Usage

  To define a schema, `use Absinthe.Schema` within
  a module. This marks your module as adhering to the
  `Absinthe.Schema` behaviour, and sets up some macros
  and utility functions for your use:

  ```
  defmodule App.Schema do
    use Absinthe.Schema

    # ... define it here!

  end
  ```

  Now, define a `query` (and optionally, `mutation`
  and `subscription`).

  We'll define a `query` that has one field, `item`, to support
  querying for an item record by its ID:

  ```
  # Just for the example. You're probably using Ecto or
  # something much more interesting than a module attribute-based
  # database!
  @fake_db %{
    "foo" => %{id: "foo", name: "Foo", value: 4},
    "bar" => %{id: "bar", name: "Bar", value: 5}
  }

  query do
    @desc "Get an item by ID"
    field :item, :item do

      @desc "The ID of the item"
      arg :id, type: :id

      resolve fn %{id: id}, _ ->
        {:ok, Map.get(@fake_db, id)}
      end
    end
  end
  ```

  For more information on object types (especially how the `resolve`
  function works above), see `Absinthe.Type.Object`.

  You may also notice we've declared that the resolved value of the field
  to be of `type: :item`. We now need to define exactly what an `:item` is,
  and what fields it contains.

  ```
  @desc "A valuable Item"
  object :item do
    field :id, :id

    @desc "The item's name"
    field :name, :string,

    field :value, :integer, description: "Recently appraised value"
  end
  ```

  We can also load types from other modules using the `import_types`
  macro:

  ```
  defmodule App.Schema do
    use Absinthe.Schema

    import_types App.Schema.Scalars
    import_types App.Schema.Objects

    # ... schema definition

  end
  ```

  Our `:item` type above could then move into `App.Schema.Objects`:

  ```
  defmodule App.Schema.Objects do
    use Absinthe.Schema.Notation

    object :item do
      # ... type definition
    end

    # ... other objects!

  end
  ```

  ## Default Resolver

  By default, if a `resolve` function is not provided for a field, Absinthe
  will attempt to extract the value of the field using `Map.get/2` with the
  (atom) name of the field.

  You can change this behavior by setting your own custom default resolve
  function in your schema. For example, given we have a field, `name`:

  ```
  field :name, :string
  ```

  And we're trying to extract values from a horrible backend API that gives us
  maps with uppercase (!) string keys:

  ```
  %{"NAME" => "A name"}
  ```

  Here's how we could set our custom resolver to expect those keys:

  ```
  default_resolve fn
    _, %{source: source, definition: %{name: name}} when is_map(source) ->
      {:ok, Map.get(source, String.upcase(name))}
    _, _ ->
      {:ok, nil}
  end
  ```

  Note this will now act as the default resolver for all fields in our schema
  without their own `resolve` function.
  """

  @typedoc """
  A module defining a schema.
  """
  @type t :: module

  alias Absinthe.Type
  alias Absinthe.Language
  alias __MODULE__

  @doc """
  Return the default middleware set for a field if none exists
  """
  def ensure_middleware([], %{identifier: identifier}, _) do
    [{Absinthe.Middleware.MapGet, identifier}]
  end
  def ensure_middleware(middleware, _field, _object) do
    middleware
  end

  defmacro __using__(opts \\ []) do
    quote do
      use Absinthe.Schema.Notation, unquote(opts)
      import unquote(__MODULE__), only: :macros

      import_types Absinthe.Type.BuiltIns

      @after_compile unquote(__MODULE__)
      @behaviour unquote(__MODULE__)

      @doc false
      def __absinthe_middleware__(middleware, field, %{name: "__" <> _} = object) do
        # if we have the double underscore prefix we're dealing with introspection
        # types, which should use the built in default middleware
        middleware
        |> Absinthe.Schema.ensure_middleware(field, object)
        |> __do_absinthe_middleware__(field, object)
      end
      def __absinthe_middleware__(middleware, field, object) do
        __do_absinthe_middleware__(middleware, field, object)
      end

      defp __do_absinthe_middleware__(middleware, field, object) do
        middleware
        |> __MODULE__.middleware(field, object) # run field against user supplied function
        |> Absinthe.Schema.ensure_middleware(field, object) # if they forgot to add middleware set the default
      end

      @doc false
      def middleware(middleware, _field, _object) do
        middleware
      end

      @doc false
      def __absinthe_lookup__(key) do
        key
        |> __absinthe_type__
        |> case do
          %Absinthe.Type.Object{} = object ->
            fields = Map.new(object.fields, fn
              {identifier, field} ->
                {identifier, %{field | middleware: __absinthe_middleware__(field.middleware, field, object)}}
            end)

            %{object | fields: fields}
          type ->
            type
        end
      end

      @doc false
      def plugins do
        Absinthe.Plugin.defaults()
      end

      defoverridable middleware: 3, plugins: 0
    end
  end

  @callback plugins() :: [Absinthe.Plugin.t]

  @doc false
  def __after_compile__(env, _bytecode) do
    [
      env.module.__absinthe_errors__,
      Schema.Rule.check(env.module)
    ]
    |> List.flatten
    |> case do
      [] ->
        nil
      details ->
        raise Absinthe.Schema.Error, details
    end
  end

  defmacro default_resolve(_) do
    raise """
    Don't use this anymore, instead use middleware, see the middleware
    module doc.

    If you had this before:
    ```
    default_resolve fn parent, _args, info ->
      # stuff here
    end
    ```

    Instead do:
    ```
    def middleware([], _field, _object) do
      middleware_spec = Absinthe.Resolution.resolver_spec(fn parent, _args, info ->
        # stuff here
      end)

      [middleware_spec]
    end
    def middleware(middleware, _, _) do
      middleware
    end
    ```
    """
    []
  end

  @default_query_name "RootQueryType"
  @doc """
  Defines a root Query object
  """
  defmacro query(raw_attrs \\ [name: @default_query_name], [do: block]) do
    record_query(__CALLER__, raw_attrs, block)
  end

  defp record_query(env, raw_attrs, block) do
    attrs =
      raw_attrs
      |> Keyword.put_new(:name, @default_query_name)
      |> Keyword.put(:identifier, :query)
    Absinthe.Schema.Notation.scope(env, :object, :query, attrs, block)
  end

  @default_mutation_name "RootMutationType"
  @doc """
  Defines a root Mutation object
  """
  defmacro mutation(raw_attrs \\ [name: @default_mutation_name], [do: block]) do
    record_mutation(__CALLER__, raw_attrs, block)
  end

  defp record_mutation(env, raw_attrs, block) do
    attrs =
      raw_attrs
      |> Keyword.put_new(:name, @default_mutation_name)
      |> Keyword.put(:identifier, :mutation)
    Absinthe.Schema.Notation.scope(env, :object, :mutation, attrs, block)
  end

  @default_subscription_name "RootSubscriptionType"
  @doc """
  Defines a root Subscription object
  """
  defmacro subscription(raw_attrs, [do: block]) do
    attrs = raw_attrs
    |> Keyword.put_new(:name, @default_subscription_name)
    Absinthe.Schema.Notation.scope(__CALLER__, :object, :subscription, attrs, block)
  end
  @doc """
  Defines a root Subscription object
  """
  defmacro subscription([do: block]) do
    Absinthe.Schema.Notation.scope(__CALLER__, :object, :subscription, [name: @default_subscription_name], block)
  end

  # Lookup a directive that in used by/available to a schema
  @doc """
  Lookup a directive.
  """
  @spec lookup_directive(t, atom | binary) :: Type.Directive.t | nil
  def lookup_directive(schema, name) do
    schema.__absinthe_directive__(name)
  end

  @doc """
  Lookup a type by name, identifier, or by unwrapping.
  """
  @spec lookup_type(atom, Type.wrapping_t | Type.t | Type.identifier_t, Keyword.t) :: Type.t | nil
  def lookup_type(schema, type, options \\ [unwrap: true]) do
    cond do
      is_atom(type) ->
        cached_lookup_type(schema, type)
      is_binary(type) ->
        cached_lookup_type(schema, type)
      Type.wrapped?(type) ->
        if Keyword.get(options, :unwrap) do
          lookup_type(schema, type |> Type.unwrap)
        else
          type
        end
      true ->
        type
    end
  end

  @doc false
  def cached_lookup_type(schema, type) do
    # TODO: elaborate on why we're using the pdict.
    case :erlang.get({schema, type}) do
      :undefined ->
        result = schema.__absinthe_lookup__(type)
        :erlang.put({schema, type}, result)
        result
      result ->
        result
    end
  end

  @doc """
  List all types on a schema
  """
  @spec types(t) :: [Type.t]
  def types(schema) do
    schema.__absinthe_types__
    |> Map.keys
    |> Enum.map(&lookup_type(schema, &1))
  end

  @doc """
  Get all concrete types for union, interface, or object
  """
  @spec concrete_types(t, Type.t) :: [Type.t]
  def concrete_types(schema, %Type.Union{} = type) do
    Enum.map(type.types, &lookup_type(schema, &1))
  end
  def concrete_types(schema, %Type.Interface{} = type) do
    implementors(schema, type)
  end
  def concrete_types(_, %Type.Object{} = type) do
    [type]
  end
  def concrete_types(_, type) do
    [type]
  end

  @doc """
  List all directives on a schema
  """
  @spec directives(t) :: [Type.Directive.t]
  def directives(schema) do
    schema.__absinthe_directives__
    |> Map.keys
    |> Enum.map(&lookup_directive(schema, &1))
  end

  @doc """
  List all implementors of an interface on a schema
  """
  @spec implementors(t, Type.identifier_t | Type.Interface.t) :: [Type.Object.t]
  def implementors(schema, ident) when is_atom(ident) do
    schema.__absinthe_interface_implementors__
    |> Map.get(ident, [])
    |> Enum.map(&lookup_type(schema, &1))
  end
  def implementors(schema, %Type.Interface{} = iface) do
    implementors(schema, iface.__reference__.identifier)
  end

  @doc false
  @spec type_from_ast(t, Language.type_reference_t) :: Absinthe.Type.t | nil
  def type_from_ast(schema, %Language.NonNullType{type: inner_type}) do
    case type_from_ast(schema, inner_type) do
      nil -> nil
      type -> %Type.NonNull{of_type: type}
    end
  end
  def type_from_ast(schema, %Language.ListType{type: inner_type}) do
    case type_from_ast(schema, inner_type) do
      nil -> nil
      type -> %Type.List{of_type: type}
    end
  end
  def type_from_ast(schema, ast_type) do
    Schema.types(schema)
    |> Enum.find(fn
      %{name: name} ->
        name == ast_type.name
    end)
  end

end
