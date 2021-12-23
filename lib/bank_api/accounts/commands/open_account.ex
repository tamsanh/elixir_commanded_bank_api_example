defmodule BankAPI.Accounts.Commands.OpenAccount do
  use TypedStruct
  import Norm
  alias BankAPI.Validation.Utils

  typedstruct do
    field :account_uuid, String.t(), enforce: true
    field :initial_balance, integer()
  end

  def valid?(%__MODULE__{} = command) do
    conform(
      command,
      schema(%{
        account_uuid: Utils.is_uuid(),
        initial_balance: Utils.is_natural_number()
      })
    )
  end
end
