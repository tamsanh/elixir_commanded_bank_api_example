defmodule BankAPI.Accounts.Projectors.AccountClosed do
  @moduledoc """
  We first lookup the task, then we update it.
  If the task doesn’t exist, I’m just ignoring it
  but proper error handling should be in place if
  this is important to your use case.
  """
  use Commanded.Projections.Ecto,
    application: BankAPI.CommandedApplication,
    name: "Accounts.Projectors.AccountClosed"

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events.AccountClosed
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.{Changeset, Multi}

  project(%AccountClosed{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(account, status: Account.status().closed)
      )
    else
      # Ignore when this happens
      _ -> multi
    end
  end)
end
