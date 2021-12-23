defmodule BankAPI.Accounts.Events.MoneyTransferRequested do
  @derive [Jason.Encoder]

  use TypedStruct

  typedstruct do
    field :transfer_uuid, String.t()
    field :source_account_uuid, String.t()
    field :destination_account_uuid, String.t()
    field :amount, integer()
  end
end
