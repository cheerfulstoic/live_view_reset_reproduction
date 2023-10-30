defmodule LiveViewResetReproductionWeb.ReproductionLive.Index do
  use LiveViewResetReproductionWeb, :live_view

  alias FuzzyMaya.GLN
  alias FuzzyMaya.GoldenRecords

  def render(assigns) do
    ~H"""
    <h1>Runs</h1>
    <form phx-change="update-runs">
      <ul>
        <li :for={run <- @matcher_runs}>
          <input checked={run.id in @run_ids} id="run_ids" name="run_ids[]" type="checkbox" value={run.id}>

          <%= run.name %>
        </li>
      </ul>
    </form>
    <h1>Results</h1>
    <table class="w-full table-fixed">
      <colgroup>
        <col class="border-b-2 w-5/12" />
        <col class="border-b-2 w-1/12" />
        <col class="border-b-2 w-5/12" />
      </colgroup>

      <thead>
        <tr>
          <th>Practitioner 1</th>
          <th>Score</th>
          <th>Practitioner 2</th>
        </tr>
      </thead>

      <tbody
        id="matches"
        phx-update="stream"
        phx-viewport-top={@page > 1 && "prev-page"}
        phx-viewport-bottom={!@end_of_timeline? && "next-page"}
        phx-page-loading
        class={[
          if(@end_of_timeline?, do: "pb-10", else: "pb-[calc(200vh)]"),
          if(@page == 1, do: "pt-10", else: "pt-[calc(200vh)]")
        ]}
      >
        <tr :for={{dom_id, match} <- @streams.matches} id={dom_id} class="columns-3 border-b-2">
          <td class="p-4">
            <%= match.record1.name %>
          </td>
          <td class="p-4">
            <div class="font-bold">
              <%= Float.round(match.score, 2) %>
            </div>
          </td>
          <td class="p-4">
            <%= match.record2.name %>
          </td>
        </tr>
      </tbody>
    </table>

    <a href="#" phx-click="load-more">Load more</a>

    <div :if={@end_of_timeline?} class="mt-5 text-[50px] text-center">
      🎉 You made it to the end 🎉
    </div>
    """
  end

  def mount(_params, %{}, socket) do
    matcher_runs = [
      %{name: "Run 1", id: 1},
      %{name: "Run 2", id: 2},
    ]

    {:ok,
     socket
     |> assign(matcher_runs: matcher_runs)
     |> assign(run_ids: [])
     |> assign(page: 1, per_page: 20)
     |> stream(:matches, [])
     |> paginate_matches(1)}
  end

  def handle_event("next-page", _, socket) do
    {:noreply, paginate_matches(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_matches(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_matches(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update-runs", %{"run_ids" => run_ids}, socket) do
  IO.inspect(run_ids, label: :run_ids)
    {:noreply,
     socket
     |> assign(:run_ids, Enum.map(run_ids, &String.to_integer/1))
     |> paginate_matches(1, true)}
  end

  defp paginate_matches(socket, new_page, reset \\ false) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns

    matches = query(socket.assigns.run_ids)

    IO.inspect(cur_page, label: :cur_page)
    IO.inspect(per_page, label: :per_page)
    {matches, at, limit} =
      if new_page >= cur_page do
        {matches, -1, per_page * 3 * -1}
      else
        {Enum.reverse(matches), 0, per_page * 3}
      end

    IO.inspect(at, label: :at)

    IO.inspect(reset, label: :reset)

    case matches do
      [] ->
        socket
        |> assign(end_of_timeline?: at == -1)

      [_ | _] = matches ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:matches, matches, at: at, limit: limit, reset: reset)
    end
  end

  # Mocking out query
  @results [
    %{id: 1, record1_id: 1, record2_id: 2, score: 1.0, run_id: 1},
    %{id: 2, record1_id: 3, record2_id: 4, score: 1.0, run_id: 1},
    %{id: 3, record1_id: 5, record2_id: 6, score: 1.0, run_id: 2},
    %{id: 4, record1_id: 7, record2_id: 8, score: 1.0, run_id: 1},
    %{id: 5, record1_id: 9, record2_id: 10, score: 1.0, run_id: 2},
    %{id: 6, record1_id: 11, record2_id: 12, score: 1.0, run_id: 1},
    %{id: 7, record1_id: 13, record2_id: 14, score: 1.0, run_id: 1},
    %{id: 8, record1_id: 15, record2_id: 16, score: 1.0, run_id: 1},
    %{id: 9, record1_id: 17, record2_id: 18, score: 1.0, run_id: 1},
    %{id: 10, record1_id: 19, record2_id: 20, score: 1.0, run_id: 1},
    %{id: 11, record1_id: 21, record2_id: 22, score: 1.0, run_id: 2},
    %{id: 12, record1_id: 23, record2_id: 24, score: 1.0, run_id: 1},
    %{id: 13, record1_id: 25, record2_id: 26, score: 1.0, run_id: 1},
    %{id: 14, record1_id: 27, record2_id: 28, score: 1.0, run_id: 1},
    %{id: 15, record1_id: 29, record2_id: 30, score: 1.0, run_id: 2},
    %{id: 16, record1_id: 31, record2_id: 32, score: 1.0, run_id: 1},
    %{id: 17, record1_id: 33, record2_id: 34, score: 1.0, run_id: 1},
    %{id: 18, record1_id: 35, record2_id: 36, score: 1.0, run_id: 1},
    %{id: 19, record1_id: 37, record2_id: 38, score: 1.0, run_id: 1},
    %{id: 20, record1_id: 39, record2_id: 40, score: 1.0, run_id: 1},
    %{id: 21, record1_id: 41, record2_id: 42, score: 1.0, run_id: 1},
    %{id: 22, record1_id: 43, record2_id: 44, score: 1.0, run_id: 1},
    %{id: 23, record1_id: 45, record2_id: 46, score: 1.0, run_id: 1},
    %{id: 24, record1_id: 47, record2_id: 48, score: 1.0, run_id: 1},
    %{id: 25, record1_id: 49, record2_id: 50, score: 1.0, run_id: 2},
    %{id: 26, record1_id: 51, record2_id: 52, score: 1.0, run_id: 1},
    %{id: 27, record1_id: 53, record2_id: 54, score: 1.0, run_id: 1},
    %{id: 28, record1_id: 55, record2_id: 56, score: 1.0, run_id: 1},
    %{id: 29, record1_id: 57, record2_id: 58, score: 1.0, run_id: 2},
    %{id: 30, record1_id: 59, record2_id: 60, score: 1.0, run_id: 2},
    %{id: 31, record1_id: 61, record2_id: 62, score: 1.0, run_id: 1},
    %{id: 32, record1_id: 63, record2_id: 64, score: 1.0, run_id: 2},
    %{id: 33, record1_id: 65, record2_id: 66, score: 1.0, run_id: 1},
    %{id: 34, record1_id: 67, record2_id: 68, score: 1.0, run_id: 1},
    %{id: 35, record1_id: 69, record2_id: 70, score: 1.0, run_id: 1},
    %{id: 36, record1_id: 71, record2_id: 72, score: 1.0, run_id: 2},
    %{id: 37, record1_id: 73, record2_id: 74, score: 1.0, run_id: 1},
    %{id: 38, record1_id: 75, record2_id: 76, score: 1.0, run_id: 2},
    %{id: 39, record1_id: 77, record2_id: 78, score: 1.0, run_id: 1},
    %{id: 40, record1_id: 79, record2_id: 80, score: 1.0, run_id: 1},
    %{id: 41, record1_id: 61, record2_id: 62, score: 1.0, run_id: 2},
    %{id: 42, record1_id: 63, record2_id: 64, score: 1.0, run_id: 1},
    %{id: 43, record1_id: 65, record2_id: 66, score: 1.0, run_id: 2},
    %{id: 44, record1_id: 67, record2_id: 68, score: 1.0, run_id: 1},
    %{id: 45, record1_id: 69, record2_id: 70, score: 1.0, run_id: 1},
    %{id: 46, record1_id: 71, record2_id: 72, score: 1.0, run_id: 2},
    %{id: 47, record1_id: 73, record2_id: 74, score: 1.0, run_id: 1},
    %{id: 48, record1_id: 75, record2_id: 76, score: 1.0, run_id: 1},
    %{id: 49, record1_id: 77, record2_id: 78, score: 1.0, run_id: 2},
    %{id: 50, record1_id: 79, record2_id: 80, score: 1.0, run_id: 2},
    %{id: 51, record1_id: 81, record2_id: 82, score: 1.0, run_id: 2},
    %{id: 52, record1_id: 83, record2_id: 84, score: 1.0, run_id: 2},
    %{id: 53, record1_id: 85, record2_id: 86, score: 1.0, run_id: 1},
    %{id: 54, record1_id: 87, record2_id: 88, score: 1.0, run_id: 1},
    %{id: 55, record1_id: 89, record2_id: 90, score: 1.0, run_id: 2},
    %{id: 56, record1_id: 91, record2_id: 92, score: 1.0, run_id: 2},
    %{id: 57, record1_id: 93, record2_id: 94, score: 1.0, run_id: 1},
    %{id: 58, record1_id: 95, record2_id: 96, score: 1.0, run_id: 2},
    %{id: 59, record1_id: 97, record2_id: 98, score: 1.0, run_id: 2},
    %{id: 60, record1_id: 99, record2_id: 100, score: 1.0, run_id: 2}
  ]

  @records Enum.map(1..100, fn i ->
    %{id: i, name: "Foo Bar #{i}"}
  end)

  def query(ids) do
  Process.sleep(100)
    @results
    |> Enum.filter(fn %{run_id: run_id} -> run_id in ids end)
    |> Enum.map(fn match ->
      match
      |> Map.put(:record1, Enum.find(@records, fn %{id: id} -> id == match.record1_id end))
      |> Map.put(:record2, Enum.find(@records, fn %{id: id} -> id == match.record2_id end))
    end)
    |> Enum.take(20)
  end
end

