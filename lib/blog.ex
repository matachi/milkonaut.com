defmodule Blog do
  @moduledoc """
  Documentation for `Blog`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Blog.hello()
      :world

  """
  use NimblePublisher,
    build: Post,
    from: "./posts/**/*.md",
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  @posts Enum.sort_by(@posts, & &1.published_at, {:desc, Date})

  # And finally export them
  def all_posts, do: @posts
end
