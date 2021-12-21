defmodule BankAPI.Router do
  @moduledoc """
  Once built by open_account/1 in our context and dispatched
  through this router, the command is handled by the Account aggregate.
  """
  use Commanded.Commands.Router

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.OpenAccount

  middleware(BankAPI.Middleware.ValidateCommand)

  dispatch([OpenAccount], to: Account, identity: :account_uuid)
end
