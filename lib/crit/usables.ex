defmodule Crit.Usables do
  alias Crit.Sql
  alias Crit.Usables.{Animal, ServiceGap, Species}
  alias Crit.Usables.Write
  alias Crit.Ecto.BulkInsert
  alias Ecto.Multi
  alias Crit.Ecto.MegaInsert
  alias Crit.Institutions
  alias Ecto.Changeset
  import Pile.Changeset, only: [ensure_forms_display_errors: 1]

  def get_complete_animal!(id, institution) do
    query = 
      Animal.Query.from(id: id) |> Animal.Query.preload_common()
    
    case Sql.one(query, institution) do
      nil ->
        raise KeyError, "No animal id #{id}"
      animal ->
        animal
    end
  end

  def get_complete_animal_by_name(name, institution) do
    Animal.Query.from(name: name)
    |> Animal.Query.preload_common()
    |> Sql.one(institution)
  end

  def create_animals(supplied_attrs, institution) do
    attrs = Map.put(supplied_attrs, "timezone", Institutions.timezone(institution))
    steps = [
      &bulk_animal__validate/1,
      &bulk_animal__split_changeset/1,
      &bulk_animal__insert/1,
      &bulk_animal__return_value/1,
    ]

    state = %{attrs: attrs, institution: institution}
    case bulk_creation_steps(state, steps) do 
      {:ok, %{animals: animals}} ->
        {:ok, animals}
      {:error, _} = error ->
        error
    end
  end

  def bulk_creation_steps(state, []),
    do: {:ok, state}
  
  def bulk_creation_steps(state, [next | rest]) do
    case next.(state) do
      {:error, changeset} ->
        {:error, ensure_forms_display_errors(changeset)}
      {:ok, state} ->
        bulk_creation_steps(state, rest)
    end
  end
        
  def bulk_animal__validate(%{attrs: attrs} = state) do
    changeset = Write.BulkAnimal.compute_insertables(attrs)
    if changeset.valid? do
      {:ok, Map.put(state, :bulk_changeset, changeset)}
    else
      {:error, changeset}
    end
  end

  def bulk_animal__split_changeset(%{bulk_changeset: changeset} = state) do
    changesets = Write.BulkAnimal.changeset_to_changesets(changeset)

    {:ok, Map.put(state, :changesets, changesets)}
  end


  def bulk_animal__insert(%{
        bulk_changeset: changeset,
        changesets: changesets,
        institution: institution} = state) do

    case bulk_insert(changesets, institution) do
      {:ok, %{animal_ids: ids}} ->
        {:ok, Map.put(state, :animal_ids, ids)}
      {:error, single_failure} ->
        duplicate = single_failure.changes.name
        message = ~s|An animal named "#{duplicate}" is already in service|
        changeset
        |> Changeset.add_error(:names, message)
        |> Changeset.apply_action(:insert)
        # Note that `apply_action` will return {:error, changeset} in this case.
    end
  end

  def bulk_animal__return_value(%{animal_ids: ids, institution: institution} = state) do
    new_state = Map.put(state, :animals, ids_to_animals(ids, institution))
    {:ok, new_state}
  end
  
    
  def create_animals_old(attrs, institution) do
    changeset =
      attrs
      |> Map.put("timezone", Institutions.timezone(institution))
      |> Write.BulkAnimal.compute_insertables

    case changeset.valid? do
      false ->
        # This makes `form_for` display the changeset errors. Bleh.
        Changeset.apply_action(changeset, :insert)
      true ->
        result =
          changeset
          |> Write.BulkAnimal.changeset_to_changesets
          |> bulk_insert(institution)

        case result do
          {:ok, %{animal_ids: ids}} ->
            {:ok, ids_to_animals(ids, institution)}
          {:error, single_failure} ->
            duplicate = single_failure.changes.name
            message = ~s|An animal named "#{duplicate}" is already in service|
            changeset
            |> Changeset.add_error(:names, message)
            |> Changeset.apply_action(:insert)
        end
    end
  end

  defp bulk_insert(
    %{animal_changesets: animal_changesets,
      service_gap_changesets: service_gap_changesets},
    institution) do 

    institution
    |> BulkInsert.three_schema_insertion(
           insert: animal_changesets, yielding: :animal_ids,
           insert: service_gap_changesets, yielding: :service_gap_ids,
           many_to_many: Write.AnimalServiceGap)
    |> Sql.transaction(institution)
    |> BulkInsert.simplify_transaction_results(:animal_ids)
  end


  def create_animal(attrs, institution) do
    attrs
    |> creation_changesets(institution)
    |> creation_continuation(institution)
  end

  defp creation_changesets(attrs, institution) do
    adjusted_attrs = Map.put(attrs, "timezone", Institutions.timezone(institution))
    
    {:ok, animal_changesets} = Animal.creational_changesets(adjusted_attrs)
    {:ok, service_gap_changesets} = ServiceGap.initial_changesets(adjusted_attrs)

    {:ok, [animal_changesets, service_gap_changesets]}
  end


  defp creation_continuation({:error, changeset}, _institution),
    do: {:error, changeset}

    # Note: there's no particular reason for this to be transactional but
  # I wanted to learn more about using Ecto.Multi.
  defp creation_continuation({:ok, [animal_changesets, service_gap_changesets]}, institution) do
    
    animal_opts = [schema: Animal, structs: :animals, ids: :animal_ids]
    service_gap_opts = [schema: ServiceGap, structs: :service_gaps, ids: :service_gap_ids]

    animal_multi =
      MegaInsert.make_insertions(animal_changesets, institution, animal_opts)
      |> MegaInsert.append_collecting(animal_opts)
    service_gap_multi =
      MegaInsert.make_insertions(service_gap_changesets, institution, service_gap_opts)
      |> MegaInsert.append_collecting(service_gap_opts)

    connector_function = fn tx_result ->
      MegaInsert.connection_records(tx_result, Write.AnimalServiceGap, :animal_ids, :service_gap_ids)
      |> MegaInsert.make_insertions(institution, schema: Write.AnimalServiceGap)
    end

    {:ok, tx_result} =
      Multi.new
      |> Multi.append(animal_multi)
      |> Multi.append(service_gap_multi)
      |> Multi.merge(connector_function)
      |> Sql.transaction(institution)

    # When I try to include the final query into the Multi, I get a
    # weird error that I think is some sort of interaction with the
    # `Sql` prefix-handling. That is,
    #        Sql.all(query, "critter4us")
    # fails, but the equivalent
    #        Crit.Repo.all(query, prefix: "demo")
    # works fine.

    animals = ids_to_animals(tx_result.animal_ids, institution)

    {:ok, animals}
    
  end

    
  def bulk_animal_creation_changeset() do
   %Write.BulkAnimal{
     names: "",
     species_id: 0,
     start_date: "today",
     end_date: "never",
     timezone: "--to be replaced--"}
     |> Write.BulkAnimal.changeset(%{})
  end

  

  def animal_creation_changeset(%Animal{} = animal) do
    Animal.changeset(animal, %{})
  end

  def available_species(institution) do
    Species.Query.ordered()
    |> Sql.all(institution)
    |> Enum.map(fn %Species{name: name, id: id} -> {name, id} end)
  end

  def ids_to_animals(ids, institution) do
    query =
      ids
      |> Animal.Query.from_ids
      |> Animal.Query.preload_common
      |> Animal.Query.ordered
    Sql.all(query, institution)
  end
end
