defmodule Haveibeenpwned.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define children to be started
    children = [
      worker(Haveibeenpwned.Database.IO, [])
    ]

    # Start the OTP application
    opts = [strategy: :one_for_one, name: Haveibeenpwned.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
