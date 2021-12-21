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
  end

  alias __MODULE__
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Events.AccountOpened

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

  def execute(%Account{}, %OpenAccount{}) do
    {:error, :account_already_opened}
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
end
