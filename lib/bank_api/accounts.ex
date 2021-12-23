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

  alias BankAPI.Repo
  alias BankAPI.CommandedApplication
  alias BankAPI.Accounts.Commands.{OpenAccount, CloseAccount}
  alias BankAPI.Accounts.Projections.Account

  def get_account(uuid), do: Repo.get!(Account, uuid)

  def close_account(uuid) do
    %CloseAccount{
      account_uuid: uuid
    }
    |> CommandedApplication.dispatch()
  end

  @doc """
  Using pattern-matching, we immediately discard calls
  not including the initial balance as an argument - we’ll
  handle this shortly in our fallback controller.
  If we do receive the proper argument, we construct the
  command and dispatch it. It will be here that the validation
  middleware will take over and do a deeper analysis.
  """
  def open_account(%{"initial_balance" => initial_balance}) do
    account_uuid = UUID.uuid4()

    dispatch_result =
      %OpenAccount{
        initial_balance: initial_balance,
        account_uuid: account_uuid
      }
      |> CommandedApplication.dispatch()

    case dispatch_result do
      :ok ->
        {
          :ok,
          %Account{
            uuid: account_uuid,
            current_balance: initial_balance,
            status: Account.status().open
          }
        }

      reply ->
        reply
    end
  end

  def open_account(_params), do: {:error, :bad_command}
end
