defmodule BankAPI.Accounts.Projectors.DepositsAndWithdrawals do
  @moduledoc """
  Since the projection logic is so simple for
  these two events (just set the balance to the
  one in the received event), we can have
  one projector for both:

  """
  use Commanded.Projections.Ecto,
    application: BankAPI.CommandedApplication,
    name: "Accounts.Projectors.AccountOpened"

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events.{DepositedIntoAccount, WithdrawnFromAccount}
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.{Changeset, Multi}

  project(%DepositedIntoAccount{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: evt.new_current_balance
        )
      )
    else
      _ -> multi
    end
  end)

  project(%WithdrawnFromAccount{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: evt.new_current_balance
        )
      )
    else
      _ -> multi
    end
  end)
end
