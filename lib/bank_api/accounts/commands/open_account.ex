defmodule BankAPI.Accounts.Commands.OpenAccount do
  use TypedStruct

  typedstruct do
    field :account_uuid, String.t(), enforce: true
    field :initial_balance, integer()
  end
end
