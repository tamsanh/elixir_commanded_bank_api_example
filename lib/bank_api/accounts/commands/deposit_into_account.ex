defmodule BankAPI.Accounts.Commands.DepositIntoAccount do
  use TypedStruct
  alias BankAPI.Validation.Utils

  use Norm

  typedstruct do
    field :account_uuid, String.t(), enforced: true
    field :deposit_amount, integer()
  end

  def valid?(command) do
    conform(
      command,
      %{
        account_uuid: Utils.is_uuid(),
        deposit_amount: Utils.is_natural_number()
      }
    )
  end
end
