defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.

  Initially, we’ll just define get_account and open_account as our public interface.
  Getting an existing account from the read model is trivial given its identifier.

  As for opening a new one, we first validate the changeset
  (done here for now, we will introduce a command validation middleware later on).
  If the changeset isn’t valid, we return an error tuple that will be handled by
  our fallback controller. If we do have a valid changeset, an OpenAccount command
  is built and dispatched. The account identifier present in the command is
  created here, using a v4 UUID. In case of a successful dispatch,
  we return a success tuple to the controller with an Account object to render.
  Notice we do not insert the account on the read model directly, instead
  relying on the command dispatch triggering a chain of events that will
  ultimately result in that insertion - routing of the command to an aggregate,
  which upon successful handling emits an event, that is then subscribed to
  by a projector, which inserts the new account.

  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias BankAPI.Repo
  alias BankAPI.Router
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Projections.Account

  def get_account(uuid), do: Repo.get!(Account, uuid)

  def open_account(account_params) do
    changeset = account_opening_changeset(account_params)

    if changeset.valid? do
      account_uuid = UUID.uuid4()

      dispatch_result =
        %OpenAccount{
          initial_balance: changeset.changes.initial_balance,
          account_uuid: account_uuid
        }
        |> Router.dispatch()

      case dispatch_result do
        :ok ->
          {
            :ok,
            %Account{
              uuid: account_uuid,
              current_balance: changeset.changes.initial_balance
            }
          }

        reply ->
          reply
      end
    else
      {:validation_error, changeset}
    end
  end

  defp account_opening_changeset(params) do
    {
      params,
      %{initial_balance: :integer}
    }
    |> Changeset.cast(params, [:initial_balance])
    |> Changeset.validate_required([:initial_balance])
    |> Changeset.validate_number(:initial_balance, greater_than: 0)
  end
end
