defmodule BankAPI.Accounts.Supervisor do
  use Supervisor

  alias BankAPI.Accounts

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      Accounts.Projectors.AccountOpened,
      Accounts.Projectors.AccountClosed
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
