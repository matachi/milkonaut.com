defmodule Post do
  @enforce_keys [:id, :title, :body, :published_at, :updated_at, :path, :url]
  defstruct [:id, :title, :body, :published_at, :updated_at, :path, :url]

  def build(filename, attrs, body) do
    path = Path.rootname(filename)
    [year, month_day_id] = path |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    path = id <> "/index.html"
    url = id
    published_at = Date.from_iso8601!("#{year}-#{month}-#{day}")
    updated_at = case attrs.updated_at do
      nil -> nil
      _ -> attrs.updated_at |> Date.from_iso8601!()
    end
    struct!(__MODULE__, [id: id, published_at: published_at, updated_at: updated_at, body: body, path: path, url: url] ++ Map.to_list(attrs))
  end
end
