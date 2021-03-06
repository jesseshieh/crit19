defmodule Crit.Exemplars.PasswordFocused do
  use ExUnit.CaseTemplate
  alias Crit.Users.{Password}
  alias Crit.Users
  use Crit.Global.Constants
  alias Crit.Exemplars.Minimal

  def params(password),
    do: params(password, password)
  
  def params(password, confirmation) do
    %{"new_password" => password,
      "new_password_confirmation" => confirmation
    }
  end

  def user(password) do
    user = Minimal.user()
    assert :ok == Users.set_password(user.auth_id, params(password, password), @institution)
    assert Password.count_for(user.auth_id, @institution) == 1
    user
  end
end
