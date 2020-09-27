defmodule PagerComponent do
  use Phoenix.LiveComponent
  import Phoenix.HTML.Link
  import Phoenix.HTML.Form, only: [form_for: 3, select: 4]

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="col-2">
        Go to page:
      </div>
      <%= for page <- pages_to_link(@page_number, @total_pages) do %>
        <div class="col-1">
          <%= link page, to: "#", class: "mr-2", phx_click: "get_page", phx_value_page: page %>
        </div>
      <% end %>
      <div class="col-2 offset-2">
        <label class="form-label">Page Size:</label>
      </div>
      <div class="col-2">
        <%= f = form_for :pager, "#", phx_change: "get_page" %>
          <%= select f, :page_size, [5, 10, 20, 50], value: @page_size, class: "form-control" %>
        </form>
      </div>
    </div>
    """
  end

  defp pages_to_link(current_page, total_pages) do
    Enum.reduce_while(1..total_pages, [1, current_page, total_pages], fn el, acc ->
      cond do
        Enum.member?(acc, el) -> {:cont, acc}
        length(Enum.uniq(acc)) >= 5 -> {:halt, acc}
        current_page < 3 -> {:cont, [el | acc]}
        el >= total_pages - 3 and current_page >= total_pages - 3 -> {:cont, [el | acc]}
        current_page == total_pages -> {:cont, [current_page - 1] ++ acc}
        true -> {:cont, [current_page - 1] ++ acc ++ [current_page + 1]}
      end
    end)
    |> Enum.sort()
    |> Enum.uniq()
  end
end
