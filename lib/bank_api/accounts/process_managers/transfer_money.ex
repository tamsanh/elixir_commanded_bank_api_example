defmodule BankAPI.Accounts.ProcessManagers.TransferMoney do
  @moduledoc """
  You can see that, just like an aggregate, we have a
  state definition in the form of a struct. We also
  need to name the manager (name must be unique
  throughout the codebase) and specify which router
  to use when we dispatch commands.

  Then, we specify which events we want to handle with
  interested?/1 functions. First off, we want to handle
  the MoneyTransferRequested event, and we return a
  tuple with start! and a UUID that will serve as an
  identifier for the Erlang process that will be started
  for this particular process manager instance. All
  further interaction with the process manager will need
  the same UUID to reach the same instance.

  """
  use Commanded.ProcessManagers.ProcessManager,
    name: "Accounts.ProcessManagers.TransferMoney",
    application: BankAPI.CommandedApplication

  @derive Jason.Encoder

  use TypedStruct

  alias BankAPI.Accounts.Events.{
    MoneyTransferRequested,
    WithdrawnFromAccount,
    DepositedIntoAccount
  }

  alias BankAPI.Accounts.Commands.{
    WithdrawFromAccount,
    DepositIntoAccount
  }

  alias __MODULE__

  typedstruct do
    field :transfer_uuid, String.t()
    field :source_account_uuid, String.t()
    field :destination_account_uuid, String.t()
    field :amount, integer()
    field :status, String.t()
  end

  @doc """
  We could have also used start without the !, but
  I’ve added the bang for extra validation that the
  process doesn’t already exist. More info at
  https://github.com/commanded/commanded/blob/master/guides/Process%20Managers.md#strict-process-routing

  The list of events we’re interested in also includes
  WithdrawnFromAccount and DepositedIntoAccount since
  these are the consequence events from the commands
  we’ll be dispatching to execute a transfer.
  https://blog.nootch.net/img/post/event-sourcing-with-elixir-part-6/transfer.png

  Note that we could have used one less “hop” in the
  flow, and have the event that kickstarts the transfer
  already withdraw money from the source account, but it’s
  important to capture intent in your domain.
  """
  def interested?(%MoneyTransferRequested{transfer_uuid: transfer_uuid}),
    do: {:start!, transfer_uuid}

  def interested?(%WithdrawnFromAccount{account_uuid: transfer_uuid}) when is_nil(transfer_uuid),
    do: false

  def interested?(%WithdrawnFromAccount{account_uuid: transfer_uuid}),
    do: {:continue!, transfer_uuid}

  def interested?(%DepositedIntoAccount{account_uuid: transfer_uuid}) when is_nil(transfer_uuid),
    do: false

  def interested?(%DepositedIntoAccount{account_uuid: transfer_uuid}), do: {:stop, transfer_uuid}

  def interested?(_event), do: false

  @doc """
  You will notice that the WithdrawFromAccount and DepositIntoAccount
  commands have been enhanced with a transfer_uuid field. This is
  to distinguish deposits and withdrawals being done as part of a
  transfer, or single operations. That is why the interested?/1
  hooks for these events match for when this field is missing so
  as to not handle them
  """
  def handle(%TransferMoney{}, %MoneyTransferRequested{
        source_account_uuid: source_account_uuid,
        amount: transfer_amount,
        transfer_uuid: transfer_uuid
      }) do
    %WithdrawFromAccount{
      account_uuid: source_account_uuid,
      withdraw_amount: transfer_amount,
      transfer_uuid: transfer_uuid
    }
  end

  def handle(
        %TransferMoney{transfer_uuid: transfer_uuid} = pm,
        %WithdrawnFromAccount{transfer_uuid: transfer_uuid}
      ) do
    %DepositIntoAccount{
      account_uuid: pm.destination_account_uuid,
      deposit_amount: pm.amount,
      transfer_uuid: pm.transfer_uuid
    }
  end

  def apply(%TransferMoney{} = pm, %MoneyTransferRequested{} = evt) do
    %TransferMoney{
      pm
      | transfer_uuid: evt.transfer_uuid,
        source_account_uuid: evt.source_account_uuid,
        destination_account_uuid: evt.destination_account_uuid,
        amount: evt.amount,
        status: :withdraw_money_from_source_account
    }
  end

  def apply(%TransferMoney{} = pm, %WithdrawnFromAccount{}) do
    %TransferMoney{
      pm
      | status: :deposit_money_in_destination_account
    }
  end
end
