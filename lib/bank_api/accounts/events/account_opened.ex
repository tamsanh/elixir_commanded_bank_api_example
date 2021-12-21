defmodule BankAPI.Accounts.Events.AccountOpened do
  @derive [Jason.Encoder]

  use TypedStruct

  typedstruct do
    field :account_uuid, String.t()
    field :initial_balance, integer()
  end
end
