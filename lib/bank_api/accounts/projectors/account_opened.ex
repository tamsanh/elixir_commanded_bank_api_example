defmodule BankAPI.Accounts.Projectors.AccountOpened do
  @moduledoc """
  The project macro facilitated by the library receives
  the event to handle, some metadata (that we won’t be using),
  and a multi1 object into which we can add operations.
  In this case, we insert a new Account using the event’s
  payload as attributes.
  """
  use Commanded.Projections.Ecto,
    application: BankAPI.CommandedApplication,
    name: "Accounts.Projectors.AccountOpened"

  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Projections.Account

  project(%AccountOpened{} = evt, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :account_opened, %Account{
      uuid: evt.account_uuid,
      current_balance: evt.initial_balance
    })
  end)
end
