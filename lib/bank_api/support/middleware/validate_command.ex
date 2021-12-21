defmodule BankAPI.Middleware.ValidateCommand do
  @moduledoc """
  Implementing the Commanded.Middleware behaviour,
  our before_dispatch function will be the gatekeeper for
  continued processing or not of the command. It is here
  that we call valid?/1 on the command’s module and pass
  on the pipeline, if valid, or halt it if there’s a
  validation error. Notice how the behaviour also includes
  functions to be performed after successful or failed dispatch.
  """
  @behaviour Commanded.Middleware

  alias Commanded.Middleware.Pipeline

  def before_dispatch(%Pipeline{command: command} = pipeline) do
    case command.__struct__.valid?(command) do
      {:ok, _} ->
        pipeline

      {:error, messages} ->
        pipeline
        |> Pipeline.respond({:error, :command_validation_failure, command, messages})
        |> Pipeline.halt()
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline
end
