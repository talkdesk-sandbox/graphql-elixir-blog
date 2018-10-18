# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Blog.Accounts.Author
alias Blog.Posts.Post
alias Blog.Comments.Comment
alias Blog.Repo

#Authors
john = Repo.insert!(%Author{
  name: "John Smith",
  email: "john.smith@mail.com",
  password: "john123"
  })

mary = Repo.insert!(%Author{
  name: "Mary Williams",
  email: "mary.williams@mail.com",
  password: "mary321"
  })

sam = Repo.insert!(%Author{
  name: "Samuel Silva",
  email: "samuel.silva@mail.com",
  password: "samsilva123"
  })

vanessa = Repo.insert!(%Author{
  name: "Vanessa Jackson",
  email: "vanessa.jackson@mail.com",
  password: "vanessajackson321"
  })

  #Posts

  ##dates
  date1 = ~D[2018-09-23]
  date2 = ~D[2018-09-24]
  date3 = ~D[2018-09-27]

  ##titles & contents (source of the content: wikipedia)
  title1 = "What is Elixir?"
  content1 = """
  Elixir is a functional, concurrent, general-purpose programming
  language that runs on the Erlang virtual machine. Elixir builds on top of
  Erlang and shares the same abstractions for building distributed,
  fault-tolerant applications. Elixir also provides a productive tooling and an
  extensible design.
  """
  title2 = "About Elixir"
  content2 = """
  Elixir is used by companies such as E-MetroTel, Pinterest and Moz.
  Elixir is also used for web development, by companies such as Bleacher Report,
  Discord, and Inverse, and for building embedded systems. The community
  organizes yearly events in United States, Europe and Japan as well as minor
  local events and conferences.
  """
  title3 = "The History of Elixir"
  content3 = """
  José Valim is the creator of the Elixir programming language, an
  R&D project of Plataformatec. His goals were to enable higher extensibility and
  productivity in the Erlang VM while keeping compatibility with Erlang's
  ecosystem.
  """
  title4 = "Phoenix Framework: What is it?"
  content4 = """
  Phoenix is a web development framework written in the functional
  programming language Elixir. Phoenix uses a server-side model-view-controller
  (MVC) pattern. Based on the Plug library, and ultimately the Cowboy Erlang
  framework, it was developed to provide highly performant and scalable web
  applications. In addition to the request/response functionality provided by the
  underlying Cowboy server, Phoenix provides soft realtime communication to
  external clients through websockets or long polling using its language agnostic
  channels feature.
  """
  title5 = "GraphQL | A query language for your API"
  content5 = """
  GraphQL is an open source data query and manipulation language, and
  a runtime for fulfilling queries with existing data. GraphQL was developed
  internally by Facebook in 2012 before being publicly released in 2015.
  
  """

post1 = Repo.insert!(%Post{
  title: title1,
  content: content1,
  created_at: date1,
  author_id: john.id
  })

post2 = Repo.insert!(%Post{
  title: title2,
  content: content2,
  created_at: date2,
  author_id: john.id
  })

post3 = Repo.insert!(%Post{
  title: title3,
  content: content3,
  created_at: date3,
  author_id: john.id
  })

post4 = Repo.insert!(%Post{
  title: title4,
  content: content4,
  created_at: date2,
  author_id: mary.id
  })

post5 = Repo.insert!(%Post{
  title: title5,
  content: content5,
  created_at: date3,
  author_id: mary.id
  })

#Comments
comment1 = Repo.insert!(%Comment{
  content: "Elixir is really cool!",
  created_at: date1,
  post_id: post1.id,
  author_id: sam.id
})

comment2 = Repo.insert!(%Comment{
  content: "Hi! When was Elixir created?",
  created_at: date3,
  post_id: post3.id,
  author_id: vanessa.id
  })

comment3 = Repo.insert!(%Comment{
  content: "Cool! Is Phoenix hard to learn?",
  created_at: date3,
  post_id: post4.id,
  author_id: vanessa.id
  })
