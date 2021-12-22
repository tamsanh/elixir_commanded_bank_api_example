defmodule BankAPI.Test.InMemoryEventStoreCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Commanded.Assertions.EventAssertions
      import BankAPI.Test.AggregateUtils
      alias Commanded.EventStore.Adapters.InMemory
    end
  end

  setup do
    {:ok, _apps} = Application.ensure_all_started(:bank_api)

    on_exit(fn ->
      :ok = Application.stop(:bank_api)
      :ok = Application.stop(:commanded)
    end)
  end
end
