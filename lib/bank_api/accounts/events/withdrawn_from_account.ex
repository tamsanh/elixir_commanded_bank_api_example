defmodule BankAPI.Accounts.Events.WithdrawnFromAccount do
  @derive [Jason.Encoder]

  use TypedStruct

  typedstruct do
    field :account_uuid, String.t()
    field :new_current_balance, integer()
    field :transfer_uuid, String.t()
  end
end
