defmodule BankAPI.Accounts.Commands.DepositIntoAccount do
  use TypedStruct
  alias BankAPI.Validation.Utils

  use Norm

  typedstruct do
    field :account_uuid, String.t(), enforced: true
    field :deposit_amount, integer()
    field :transfer_uuid, String.t()
  end

  def valid?(command) do
    conform(
      command,
      %{
        account_uuid: Utils.is_uuid(),
        deposit_amount: Utils.is_natural_number(),
        transfer_uuid: Utils.is_uuid()
      }
    )
  end
end
