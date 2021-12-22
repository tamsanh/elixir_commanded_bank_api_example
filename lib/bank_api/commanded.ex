defmodule BankAPI.CommandedApplication do
  use Commanded.Application, otp_app: :bank_api

  router(BankAPI.Router)
end
