# BankAPI

## Overview

This repository is an effective clone of the [Event Sourcing With Elixir series by Bruno Antunes](https://blog.nootch.net/post/event-sourcing-with-elixir-part-1/), but updated to address the never versions of packages and modules that have come out since 2019, when Bruno first wrote his series.

It should serve as an introductory example of a fully working Commanded + Pheonix application.

Some design choices from the original blog may not be the best choices for your own environment, so please consider carefully how your own domains should be segregated before immediately copying the loose structure that's exhibited in this example.

A big thank you to Bruno Antunes for his entire series.

## Usage

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
