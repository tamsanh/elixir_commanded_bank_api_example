defmodule BankAPIWeb.AccountController do
  use BankAPIWeb, :controller

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Projections.Account

  action_fallback BankAPIWeb.FallbackController

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.open_account(account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", account: account)
    end
  end

  def delete(conn, %{"id" => account_id}) do
    with :ok <- Accounts.close_account(account_id) do
      conn
      |> send_resp(200, "")
    end
  end

  def show(conn, %{"id" => account_id}) do
    with {:ok, %Account{} = account} <- Accounts.get_account(account_id) do
      conn
      |> put_status(:ok)
      |> render("show.json", account: account)
    end
  end
end
