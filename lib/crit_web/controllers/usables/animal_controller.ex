defmodule CritWeb.Usables.AnimalController do
  use CritWeb, :controller

  # alias Crit.Usables
  # alias Crit.Usables.Animal

  # def index(conn, _params) do
  #   animals = Usables.list_animals()
  #   render(conn, "index.html", animals: animals)
  # end

  # def new(conn, _params) do
  #   changeset = Usables.change_animal(%Animal{})
  #   render(conn, "new.html", changeset: changeset)
  # end

  # def create(conn, %{"animal" => animal_params}) do
  #   case Usables.create_animal(animal_params) do
  #     {:ok, animal} ->
  #       conn
  #       |> put_flash(:info, "Animal created successfully.")
  #       |> redirect(to: Routes.usables_animal_path(conn, :show, animal))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "new.html", changeset: changeset)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   animal = Usables.get_animal!(id)
  #   render(conn, "show.html", animal: animal)
  # end

  # def edit(conn, %{"id" => id}) do
  #   animal = Usables.get_animal!(id)
  #   changeset = Usables.change_animal(animal)
  #   render(conn, "edit.html", animal: animal, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "animal" => animal_params}) do
  #   animal = Usables.get_animal!(id)

  #   case Usables.update_animal(animal, animal_params) do
  #     {:ok, animal} ->
  #       conn
  #       |> put_flash(:info, "Animal updated successfully.")
  #       |> redirect(to: Routes.usables_animal_path(conn, :show, animal))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", animal: animal, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   animal = Usables.get_animal!(id)
  #   {:ok, _animal} = Usables.delete_animal(animal)

  #   conn
  #   |> put_flash(:info, "Animal deleted successfully.")
  #   |> redirect(to: Routes.usables_animal_path(conn, :index))
  # end
end
