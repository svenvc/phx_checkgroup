defmodule SensorMonitor.ReportQuery do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :begin_date, :date
    field :end_date, :date
    field :days, {:array, :integer}, default: [1, 2, 3, 4, 5]
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:begin_date, :end_date, :days])
    |> validate_required([:begin_date, :end_date, :days])
    |> validate_begin_end_date()
    |> update_change(:days, fn days -> Enum.reject(days, fn x -> x == "" end) end)
    |> validate_subset(:days, 1..7)
    |> validate_length(:days, min: 1, message: "Pick at least one weekday")
  end

  defp validate_begin_end_date(changeset) do
    begin_date = get_field(changeset, :begin_date)
    end_date = get_field(changeset, :end_date)

    if begin_date && end_date && Date.after?(begin_date, end_date) do
      changeset
      |> add_error(:begin_date, "Begin must come before end")
      |> add_error(:end_date, "End must come after begin")
    else
      changeset
    end
  end
end
