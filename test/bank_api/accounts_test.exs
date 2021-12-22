defmodule BankAPI.Accounts.AccountsTest do
  use BankAPI.Test.InMemoryEventStoreCase

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Projections.Account

  test "opens account with valid command" do
    params = %{
      "initial_balance" => 1_000
    }

    assert {:ok,
            %Account{
              current_balance: 1_000
            }} = Accounts.open_account(params)
  end

  test "does not dispatch command with invalid payload" do
    params = %{
      "initial_whatevs" => 1_0000
    }

    assert {:error, :bad_command} = Accounts.open_account(params)
  end

  test "returns validation errors from dispatch" do
    params1 = %{
      "initial_balance" => "1_000"
    }

    params2 = %{
      "initial_balance" => -10
    }

    params3 = %{
      "initial_balance" => 0
    }

    assert {
             :error,
             :command_validation_failure,
             _cmd,
             [%{input: "1_000", path: [:initial_balance], spec: "is_integer()"}]
           } = Accounts.open_account(params1)

    assert {
             :error,
             :command_validation_failure,
             _cmd,
             [%{input: -10, path: [:initial_balance], spec: "&(&1 > 0)"}]
           } = Accounts.open_account(params2)

    assert {
             :error,
             :command_validation_failure,
             _cmd,
             [%{input: 0, path: [:initial_balance], spec: "&(&1 > 0)"}]
           } = Accounts.open_account(params3)
  end
end
