defmodule BankAPIWeb.PageController do
  use BankAPIWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
