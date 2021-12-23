defmodule BankAPI.Accounts.Events.AccountClosed do
  use TypedStruct

  typedstruct do
    field :account_uuid, String.t(), enforced: true
  end
end
