defmodule BankAPI.Accounts.Aggregates.Account do
  @moduledoc """
  One of our execute/2 functions matches an aggregate
  with no UUID (an account not yet open) and a
  given command with an initial_balance argument over 0 and
  emits an AccountOpened event as a result. The apply/2 method
  applies this event and changes the aggregate’s internal state
  to match its payload.
  """
  use TypedStruct

  typedstruct do
    field :uuid, String.t()
    field :current_balance, integer()
    field :closed?, boolean(), default: false
  end

  alias __MODULE__

  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount,
    TransferBetweenAccounts
  }

  alias BankAPI.Accounts.Events.{
    AccountOpened,
    AccountClosed,
    DepositedIntoAccount,
    WithdrawnFromAccount,
    MoneyTransferRequested
  }

  def execute(
        %Account{uuid: nil},
        %OpenAccount{
          account_uuid: account_uuid,
          initial_balance: initial_balance
        }
      )
      when initial_balance > 0 do
    %AccountOpened{
      account_uuid: account_uuid,
      initial_balance: initial_balance
    }
  end

  def execute(
        %Account{uuid: nil},
        %OpenAccount{
          initial_balance: initial_balance
        }
      )
      when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  def execute(
        %Account{},
        %OpenAccount{}
      ) do
    {:error, :account_already_opened}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %CloseAccount{
          account_uuid: account_uuid
        }
      ) do
    {:error, :account_already_closed}
  end

  def execute(%Account{uuid: account_uuid, closed?: false}, %CloseAccount{
        account_uuid: account_uuid
      }) do
    %AccountClosed{
      account_uuid: account_uuid
    }
  end

  def execute(%Account{}, %CloseAccount{}) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %DepositIntoAccount{account_uuid: account_uuid, deposit_amount: amount}
      ) do
    %DepositedIntoAccount{
      account_uuid: account_uuid,
      new_current_balance: current_balance + amount
    }
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %DepositIntoAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %DepositIntoAccount{}
      ) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %WithdrawFromAccount{account_uuid: account_uuid, withdraw_amount: amount}
      ) do
    new_balance = current_balance - amount

    if new_balance > 0 do
      %WithdrawnFromAccount{
        account_uuid: account_uuid,
        new_current_balance: new_balance
      }
    else
      {:error, :insufficient_funds}
    end
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %WithdrawnFromAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %WithdrawFromAccount{}
      ) do
    {:error, :not_found}
  end

  @doc """
  We handle the command as with all previous ones. We
  match on closed accounts and if the destination
  account is the same as the source one, we throw
  an error. We also check for sufficient funds for
  the transfer. The event we emit here will be the
  one the process manager will pick up on and start
  the transfer.
  """
  def execute(
        %Account{
          uuid: account_uuid,
          closed?: true
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid
        }
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          destination_account_uuid: destination_account_uuid
        }
      )
      when account_uuid == destination_account_uuid do
    {:error, :transfer_to_same_account}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false,
          current_balance: current_balance
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_amount: transfer_amount
        }
      )
      when current_balance < transfer_amount do
    {:error, :unsufficient_funds}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false
        },
        %TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_uuid: transfer_uuid,
          transfer_amount: transfer_amount,
          destination_account_uuid: destination_account_uuid
        }
      ) do
    %MoneyTransferRequested{
      transfer_uuid: transfer_uuid,
      source_account_uuid: account_uuid,
      amount: transfer_amount,
      destination_account_uuid: destination_account_uuid
    }
  end

  def execute(
        %Account{},
        %TransferBetweenAccounts{}
      ) do
    {:error, :not_found}
  end

  def apply(
        %Account{} = account,
        %AccountOpened{
          account_uuid: account_uuid,
          initial_balance: initial_balance
        }
      ) do
    %Account{
      account
      | uuid: account_uuid,
        current_balance: initial_balance
    }
  end

  def apply(
        %Account{uuid: account_uuid} = account,
        %AccountClosed{
          account_uuid: account_uuid
        }
      ) do
    %Account{
      account
      | closed?: true
    }
  end

  @doc """
  The logic is very similar for withdrawals and deposits.
  We match against closed accounts first, and then in
  the case of withdrawals we also check if the current
  balance is enough before we emit the event.
  Notice that the event doesn’t have the amount of the
  deposit or withdrawal, but just the new balance of
  the aggregate. This makes our lives easier when
  projecting these events onto the read-model.

  """
  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %DepositedIntoAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %WithdrawnFromAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{} = account,
        %MoneyTransferRequested{}
      ) do
    account
  end
end
