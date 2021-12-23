defmodule BankAPI.Validation.Utils do
  import Norm

  @uuid_regex ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  def is_uuid() do
    spec(is_binary() and (&String.match?(&1, @uuid_regex)))
  end

  def is_natural_number() do
    spec(is_integer() and (&(&1 > 0)))
  end
end
