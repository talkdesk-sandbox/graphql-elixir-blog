#!/usr/bin/env ruby

require 'graphlient'
require 'pry-nav'

client = Graphlient::Client.new(ENV["GRAPHQL_URL"],
  headers: {
  }
)
client.schema

AuthorsQuery = client.parse do
  query do
    authors do
      id
      name
      posts do
        title
        content
      end
    end
  end
end

result = client.execute(AuthorsQuery)

i = 0
j = 0
while i < result.data.authors.count
  puts result.data.authors[i].name
  j = 0
  while j < result.data.authors[i].posts.count
    puts result.data.authors[i].posts[j].title
    puts result.data.authors[i].posts[j].content
    j+=1
  end
  i += 1
end
