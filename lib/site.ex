defmodule Site do
  use Phoenix.Component
  import Phoenix.HTML

  @base_url "http://localhost:8000"
  @output_dir "./output"
  @assets_dir "./assets"

  slot :inner_block
  attr :base_url, :string, required: true
  def header_partial(assigns) do
    ~H"""
    <header class="push_double--ends align--center">
      <a class="undecorated" aria-label="All posts from Daniel Jonsson" href={@base_url}>
        <img src={@base_url <> "/assets/avatar.webp"} class="avatar i-flex">
        <p class="txt--x-small txt--subtle txt--uppercase txt--normal txt--spread flush--top">
          Daniel Jonsson
        </p>
      </a>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end

  slot :inner_block
  attr :base_url, :string, required: true
  def footer_partial(assigns) do
    ~H"""
    <footer class="push_double--top align--center">
      <p class="txt--x-small txt--subtle txt--uppercase txt--normal txt--spread flush--top">
        About Daniel Jonsson
      </p>
      <.about_partial base_url={@base_url} />
    </footer>
    """
  end

  def about_partial(assigns) do
    ~H"""
    <div class="bio txt--small txt--subtle push--bottom">
      <div class="trix-content">Experienced lead developer and freelancer delivering pragmatic and robust solutions. Skilled across web, mobile, desktop, and embedded systems, and currently involved in a start-up venture. Proud husband, father, and follower of Christ. Open to connecting for business opportunities.</div>
    </div>
    <section class="subscription align--center push_double--bottom txt--x-small txt--subtle">
      <label for="subscriber_email_address" class="flush--top push_quarter--bottom">
        Subscribe to get future posts via the <a class="permalink" href={@base_url <> "/feed.atom"}>RSS feed</a>.
      </label>
    </section>
    """
  end

  def post(assigns) do
    ~H"""
    <.layout base_url={@base_url} url={@base_url <> "/" <> @post.url} title={@post.title} description={@post.body}>
      <.header_partial base_url={@base_url} />
      <p class="txt--x-small txt--subtle align--center push_half--bottom">
        <%= @post.published_at %>
      </p>
      <h2 class="hdg hdg--xx-large align--center push_quarter--bottom flush--top txt--break-words " dir="auto">
        <span><%= raw @post.title %></span>
      </h2>
      <section class="push_double--ends pad--bottom">
        <article>
          <div class="trix-content">
            <%= raw @post.body %>
          </div>
        </article>
      </section>
      <.footer_partial base_url={@base_url} />
    </.layout>
    """
  end

  def index(assigns) do
    ~H"""
    <.layout base_url={@base_url} url={@base_url} title="Daniel Jonsson" description="Daniel Jonsson">
      <.header_partial base_url={@base_url}>
        <.about_partial base_url={@base_url} />
      </.header_partial>

      <article class="card card--list push--bottom" :for={post <- @posts}>
        <header class="align--center">
          <div class="card__date txt--x-small flush--top push_quarter--bottom txt--subtle">
            <span><%= post.published_at %></span>
          </div>
          <h2 class="hdg hdg--x-large flush--top" dir="auto">
            <%= post.title %>
          </h2>
        </header>

        <div class="card__content" dir="auto">
          <%= truncate_string(post.body) %>
        </div>

        <a class="card__link" aria-label={"Post: #{post.title}, on #{post.published_at}"} href={@base_url <> "/" <> post.url}>Read more</a>

        <div class="card__more txt--x-small" aria-hidden="true">
          <span class="btn btn--subtle">Read more</span>
        </div>
      </article>
    </.layout>
    """
  end

  def atom_feed(assigns) do
    raw("""
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Daniel Jonsson</title>
      <link href="#{@base_url <> "/feed.atom"}" rel="self" />
      <link href="#{@base_url}" />
      <id>urn:uuid:1099970b-7ebd-4001-a778-c31208ca587d</id>
      <updated>#{DateTime.utc_now() |> DateTime.to_iso8601()}</updated>
      #{for post <- assigns.posts do
        """
        <entry>
          <id>urn:uuid:#{post.id}</id>
          <published>#{post.published_at}</published>
          <updated>#{post.updated_at || post.published_at}</updated>
          <link rel="alternate" type="text/html" href="#{@base_url <> "/" <> post.url}" />
          <title>#{post.title}</title>
          <author>
            <name>Daniel Jonsson</name>
            <email>daniel.jonsson@kalyna.se</email>
          </author>
          <content type="html">#{post.body}</content>
        </entry>
        """
      end}
    </feed>
    """)
  end

  def layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= @title %></title>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="stylesheet" href={@base_url <> "/assets/style.css"} media="all" />
      <link rel="alternate" type="application/atom+xml" title="Feed" href={@base_url <> "/feed.atom"}>
      <link rel="apple-touch-icon" sizes="300x300" href={@base_url <> "/assets/avatar.webp"}>
      <link rel="icon" type="image/png" sizes="300x300" href={@base_url <> "/assets/avatar.webp"}>
      <meta name="twitter:card" content="summary">
      <meta name="twitter:image" content={@base_url <> "/assets/avatar.webp"}>
      <meta property="og:type" content="article">
      <meta property="og:url" content={@url}>
      <meta property="og:title" content={@title}>
      <meta property="og:description" content={truncate_string(@description)}>
      <meta property="og:image" content={@base_url <> "/assets/avatar.webp"}>
    </head>
    <body>
      <main id="main-content" class="page page--medium@medium">
        <div class="page__content">
          <%= render_slot(@inner_block) %>
        </div>
      </main>
    </body>
    </html>
    """
  end

  def truncate_string(html_string) do
    text = Regex.replace(~r/<[^>]*>/, html_string, "")
    if String.length(text) > 347 do
      String.slice(text, 0, 347) <> "…"
    else
      text
    end
  end

  def build() do
    # Clear the output directory
    File.rm_rf!(@output_dir)
    File.mkdir_p!(@output_dir)

    # Copy assets folder into the output directory
    File.cp_r!(@assets_dir, Path.join(@output_dir, "assets"))

    # Process and render files
    posts = Blog.all_posts()
    render_file("index.html", index(%{posts: posts, base_url: @base_url}))
    render_file("feed.atom", atom_feed(%{posts: posts, base_url: @base_url}))
    for post <- posts do
      dir = Path.dirname(post.path)
      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end
      render_file(post.path, post(%{post: post, base_url: @base_url}))
    end

    :ok
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
