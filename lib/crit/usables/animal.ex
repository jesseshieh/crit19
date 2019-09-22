defmodule Crit.Usables.Animal do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crit.Usables.{ServiceGap, Species, AnimalServiceGap}
  alias Crit.Ecto.{NameList, TrimmedString}


  schema "animals" do
    field :name, TrimmedString
    field :available, :boolean, default: true
    field :lock_version, :integer, default: 1
    
    
    belongs_to :species, Species
    many_to_many :service_gaps, ServiceGap, join_through: AnimalServiceGap

    field :names, NameList, virtual: true
    
    timestamps()
  end

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [:name, :species_id, :lock_version])
    |> validate_required([:name, :species_id, :lock_version])
    |> unique_constraint(:name, name: "unique_available_names")
  end

  def creational_changesets(attrs) do
    checked_input = 
      %__MODULE__{}
      |> cast(attrs, [:names, :species_id, :lock_version])
      |> validate_required([:names, :species_id, :lock_version])

    spread_names = fn changeset -> 
      Enum.map(changeset.changes.names, fn name ->
        put_change(changeset, :name, name)
      end)
    end

    case checked_input.valid? do
      false -> {:error, checked_input}
      true -> {:ok, spread_names.(checked_input)}
    end
  end

  defmodule Query do
    import Ecto.Query
    alias Crit.Usables.Animal

    def from(where) do
      from Animal, where: ^where
    end

    def from_ids(ids) do
      from a in Animal, where: a.id in ^ids
    end

    def preload_common(query) do
      query |> preload([:service_gaps, :species])
    end

    def ordered(query) do
      query |> order_by([a], a.name)
    end
  end
end
