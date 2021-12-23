defmodule BankAPI.Accounts.Commands.WithdrawFromAccount do
  use TypedStruct
  import Norm

  alias BankAPI.Validation.Utils

  typedstruct do
    field :account_uuid, String.t(), enforced: true
    field :withdraw_amount, integer()
    field :transfer_uuid, String.t()
  end

  def valid?(%__MODULE__{} = command) do
    conform(
      command,
      %{
        account_uuid: Utils.is_uuid(),
        withdraw_amount: Utils.is_natural_number(),
        transfer_uuid: Utils.is_uuid()
      }
    )
  end
end
