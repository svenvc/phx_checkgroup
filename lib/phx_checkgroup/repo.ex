defmodule PhxCheckgroup.Repo do
  use Ecto.Repo,
    otp_app: :phx_checkgroup,
    adapter: Ecto.Adapters.Postgres
end
