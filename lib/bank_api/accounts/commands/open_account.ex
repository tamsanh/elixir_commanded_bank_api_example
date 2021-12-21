defmodule BankAPI.Accounts.Commands.OpenAccount do
  use TypedStruct
  import Norm

  @uuid_regex ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  typedstruct do
    field :account_uuid, String.t(), enforce: true
    field :initial_balance, integer()
  end

  def valid?(%__MODULE__{} = command) do
    conform(
      command,
      schema(%{
        account_uuid: spec(is_binary() and (&String.match?(&1, @uuid_regex))),
        initial_balance: spec(is_integer() and (&(&1 > 0)))
      })
    )
  end
end
