defmodule CritWeb.ConnExtras do
  use Phoenix.ConnTest
  import ExUnit.Assertions
  alias Crit.Factory

  def flash_error(conn),
    do: Plug.Conn.get_session(conn, :phoenix_flash)["error"]

  def flash_info(conn),
    do: Plug.Conn.get_session(conn, :phoenix_flash)["info"]

  def assert_no_flash(conn),
    do: refute Plug.Conn.get_session(conn, :phoenix_flash)

  def standard_blank_error, do: "can&#39;t be blank"

  def assert_user_sees(conn, claims) when is_list(claims), 
    do: for claim <- claims, do: assert_user_sees(conn, claim)

  def assert_user_sees(conn, claim),
    do: assert html_response(conn, 200) =~ claim

  def refute_user_sees(conn, claim),
    do: refute html_response(conn, 200) =~ claim

  def assert_purpose(conn, purpose),
    do: assert html_response(conn, 200) =~
      ~r/Purpose:[[:space:]]+#{Regex.escape(purpose)}/

  def logged_in_as_user_manager(conn) do
    permissions = Factory.build(:permission_list, manage_and_create_users: true)
    manager = Factory.build(:user, permission_list: permissions)
    assign(conn, :current_user, manager)
  end
  
end
