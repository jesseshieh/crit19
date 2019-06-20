defmodule Spikes.ReservationBundle do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Ecto2.Timespan
  import Ecto2.Timespan

  schema "reservation_bundles" do
    field :name, :string
    field :relevant_during, Ecto2.Timespan

    many_to_many :animals, Spikes.Animal,
      join_through: "animals__reservation_bundles"

    many_to_many :procedures, Spikes.Procedure,
      join_through: "reservation_bundles__procedures"

    timestamps()
  end

  # Queries

  def bundle_animal_ids(bundle_id, timespan) do
    from arb in "animals__reservation_bundles",
      where: arb.reservation_bundle_id == ^bundle_id,
      select: %{animal_id: arb.animal_id}
  end

  def bundles(desired_timespan) do
    from b in __MODULE__,
      where: contains(b.relevant_during, ^Timespan.dump!(desired_timespan))
  end
end
