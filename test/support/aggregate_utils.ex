defmodule BankAPI.Test.AggregateUtils do
  @moduledoc """
  We use our evolve function to layer a list of
  events onto the aggregate and then assert its
  final state. Not super useful yet, as we have
  only one event - we’re sure to get more use
  out of it once we have more complex aggregate
  state being built by more event combinations.
  """
  def evolve(aggregate, events) do
    Enum.reduce(
      List.wrap(events),
      aggregate,
      &aggregate.__struct__.apply(&2, &1)
    )
  end
end
