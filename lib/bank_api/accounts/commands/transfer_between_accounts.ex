defmodule BankAPI.Accounts.Commands.TransferBetweenAccounts do
  use TypedStruct
  import Norm

  alias BankAPI.Repo
  alias BankAPI.Accounts
  alias BankAPI.Validation.Utils
  alias BankAPI.Accounts.Projections.Account

  typedstruct do
    field :account_uuid, String.t(), enforced: true
    field :transfer_uuid, String.t(), enforced: true
    field :transfer_amount, integer()
    field :destination_account_uuid, String.t()
  end

  @doc """
  This might be a bit controversial, but we do check
  the read model to validate this command.
  We don’t want to allow transfers to closed or
  non-existing accounts.
  """
  def valid?(
        %__MODULE__{
          account_uuid: account_uuid,
          destination_account_uuid: destination_account_uuid
        } = command
      ) do
    with %Account{} <- account_exists?(destination_account_uuid),
         true <- account_open?(destination_account_uuid),
         %Account{} <- account_exists?(account_uuid),
         true <- account_open?(account_uuid) do
      conform(command, schema())
    else
      nil -> {:error, ["Account missing"]}
      false -> {:error, ["Account closed"]}
    end
  end

  defp schema() do
    %{
      account_uuid: Utils.is_uuid(),
      transfer_uuid: Utils.is_uuid(),
      transfer_amount: Utils.is_natural_number(),
      destination_account_uuid: Utils.is_uuid()
    }
  end

  defp account_exists?(uuid) do
    Repo.get(Account, uuid)
  end

  defp account_open?(uuid) do
    account = Repo.get!(Account, uuid)
    account.status == Account.status().open
  end
end
