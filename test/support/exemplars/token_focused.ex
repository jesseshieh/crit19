defmodule Crit.Exemplars.TokenFocused do
  use ExUnit.CaseTemplate
  use Crit.Global.Constants
  alias Crit.Users
  alias Crit.Factory
  alias Crit.Users.UserHavingToken, as: UT


  def possible_user(attrs \\ []) do
    params = Factory.string_params_for(:user, attrs)
    Users.create_unactivated_user(params, @institution)
  end

  def user(attrs \\ []) do
    {:ok, %UT{} = tokenized} = possible_user(attrs)
    tokenized
  end

end
