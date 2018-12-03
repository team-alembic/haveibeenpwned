defmodule Haveibeenpwned.Application do
  @moduledoc """
  Defines the OTP application behaviour of :haveibeenpwned
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Start the OTP application
    opts = [strategy: :one_for_one, name: Haveibeenpwned.Supervisor]
    Supervisor.start_link([], opts)
  end
end
