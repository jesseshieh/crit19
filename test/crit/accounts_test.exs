defmodule Crit.AccountsTest do
  use Crit.DataCase

  alias Crit.Accounts

  describe "users" do
    alias Crit.Accounts.User

    test "list_users/0 returns all users" do
      user = saved_user()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = saved_user()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      attrs = user_attrs()
      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert_same_values(user, attrs, [:active, :email, :name])
      assert String.length(user.password_hash) > 100
    end

    test "create_user/1 with missing data returns error changeset" do
      assert {:error, changeset} = Accounts.create_user(%{})
      assert_has_exactly_these_keys(changeset.errors, [:email, :name, :password])
    end
 
    test "create_user/1 with invalid data returns error changeset" do
     assert {:error, changeset} = Accounts.create_user(
        %{"name" => "a", "email" => "a@b", "password" => ""})
      assert_has_exactly_these_keys(changeset.errors, [:email, :name, :password])
    end

    test "create_user/1 prevents duplicate emails" do
      unique = "unique@unique.com"
      saved_user(email: unique)
      new_user_attrs = user_attrs(email: unique)
      assert {:error, changeset} = Accounts.create_user(new_user_attrs)
      assert_has_exactly_these_keys(changeset.errors, [:email])
    end

    test "update_user/2 with valid non-password fields" do
      original = saved_user(%{name: "First name"})
      assert {:ok, updated} = Accounts.update_user(original, %{name: "Second name"})
      assert updated.name == "Second name"
      assert_same_values(original, updated, [:password_hash, :active, :email])
    end

    test "changeset/1 returns a user changeset" do
      # The changeset used for initial creation.
      assert changeset = Accounts.changeset(%User{})
      assert changeset.data == %User{}
      assert changeset.action == nil

      # The changeset used for updating.
      user = saved_user()
      assert changeset = Accounts.changeset(user)
      assert changeset.data == user
      assert changeset.action == nil
    end
  end

  describe "user authentication" do
    setup do
      data = %{ 
        id: "valid@example.com",
        password: "a valid password",
        different_id: "DIFFERENT@example.com",
        different_password: "a DIFFERENT PASSWORD",
      }

      user = saved_user(email: data.id, password: data.password)
      
      [data: Map.put(data, :user, user)]
    end

    test "success case", %{data: data} do
      user = data.user
      assert {:ok, ^user} = Accounts.authenticate_user(data.id, data.password)
    end

    test "unknown user", %{data: data} do
      assert :error = Accounts.authenticate_user(data.different_id, data.password)
    end

    test "bad password", %{data: data} do
      assert :error = Accounts.authenticate_user(data.id, data.different_password)
    end
  end
end
