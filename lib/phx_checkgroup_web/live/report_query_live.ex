defmodule PhxCheckgroupWeb.ReportQueryLive do
  use PhxCheckgroupWeb, :live_view
  alias PhxCheckgroup.ReportQuery
  alias Ecto.Changeset

  @weekdays [
    {"Monday", "1"},
    {"Tuesday", "2"},
    {"Wednesday", "3"},
    {"Thursday", "4"},
    {"Friday", "5"},
    {"Saterday", "6"},
    {"Sunday", "7"}
  ]

  defp weekdays, do: @weekdays

  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div class="mx-auto max-w-sm">
      <div class="text-5xl text-center font-extrabold border-b-4 border-amber-300 mb-10">
        Report Query
      </div>

      <.form for={@form} id="report_query_form" phx-change="validate" phx-submit="run-report">
        <.input field={@form[:begin_date]} type="date" label="Begin" required />
        <.input field={@form[:end_date]} type="date" label="End" required />
        <.checkgroup field={@form[:days]} label="Weekdays" options={weekdays()} />
        <div class="mt-6">
          <.button phx-disable-with="Running report..." class="w-full">
            Run Report<span aria-hidden="true"> →</span>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign_new_form()
    |> then(fn s -> {:ok, s} end)
  end

  defp assign_new_form(socket) do
    changeset =
      %ReportQuery{}
      |> ReportQuery.changeset(%{
        begin_date: Date.utc_today() |> Date.add(-3),
        end_date: Date.utc_today()
      })

    report_query = changeset |> Changeset.apply_action!(:update)
    changeset = report_query |> ReportQuery.changeset(%{})
    form = to_form(changeset)

    IO.inspect(form, label: "Form")

    socket
    |> assign(report_query: report_query)
    |> assign(form: form)
  end

  def handle_event("validate", %{"report_query" => report_query_params}, socket) do
    changeset = ReportQuery.changeset(socket.assigns.report_query, report_query_params)

    IO.inspect(changeset, label: "Validate changeset", limit: :infinity)

    form = to_form(changeset, action: :validate)

    IO.inspect(form, label: "Validate form")

    socket
    |> assign(form: form)
    |> then(fn s -> {:noreply, s} end)
  end

  def handle_event("run-report", %{"report_query" => report_query_params}, socket) do
    report_query =
      ReportQuery.changeset(socket.assigns.report_query, report_query_params)
      |> Changeset.apply_changes()

    report_query =
      %ReportQuery{}
      |> ReportQuery.changeset(report_query |> Map.from_struct())
      |> Changeset.apply_action!(:update)

    IO.inspect(report_query, label: "Run report")

    socket
    |> put_flash(:info, inspect(report_query))
    |> then(fn s -> {:noreply, s} end)
  end
end
