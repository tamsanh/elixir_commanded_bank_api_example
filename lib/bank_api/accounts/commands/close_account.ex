defmodule BankAPI.Accounts.Commands.CloseAccount do
  use TypedStruct
  alias BankAPI.Validation.Utils
  import Norm

  typedstruct do
    field :account_uuid, String.t(), enforced: true
  end

  def valid?(%__MODULE__{} = command) do
    conform(
      command,
      schema(%{
        account_uuid: Utils.is_uuid()
      })
    )
  end
end
