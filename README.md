# Have I Been Pwned?
[![Build status](https://badge.buildkite.com/0fd47b708e0e4e4a9af17bb8986598c3ddc0b937037443d2a6.svg)](https://buildkite.com/alembic/have-i-been-pwned)

An Elixir hex package allowing developers to check if a new user password has 
been pwned, as indicated by Troy Hunt's [Have I Been Pwned?](https://haveibeenpwned.com/)

We do not use the HIBP API to check passwords, this package takes a different 
approach. Instead, we provide a downloadable binary file which is binary 
searched near instantaneously at runtime. You can use this mix task to download 
the file, which is ~12GB in size.

This approach may not work for all deployment scenarios, so please consider 
if this package is right for you. In the future, we will be providing an API
version of this package.

## Why?

If your deployment scenario allows it, we believe this to be a powerful
approach as it can be applied within your own network without being dependent
on the uptime or connectivity of a third party service.

## Installation

Add the `:haveibeenpwned` app to your dependencies in `mix.exs`

```elixir
def deps do
  [
    {:haveibeenpwned, "~> 0.1.0"}
  ]
end
```

## Setup

The next step is to download the database. This can be done via a mix task.

```bash
$ mix hibp.download
```

The database is ~12GB in size and hosted in an S3 bucket located in Sydney,
Australia. In the future, we will provide an API version of this package for
those who cannot deploy a 12GB dependency to production.

## Usage

Check if a password has been pwned. If it has been, you will receive a warning
tuple with a count of how many times it has been pwned.

```elixir
iex(1)> Haveibeenpwned.Database.password_pwned?("12345")
{:warning, 612}
```

When a password has not been pwned, you'll receive an ok tuple with the original
password

```elixir
iex(2)> Haveibeenpwned.Database.password_pwned?("unique password")
{:ok, "unique_password"}
```

## Examples

This can be quite useful in a registration flow. For example, you might want
to invalidate a User changeset if the supplied password is pwned

```elixir
defmodule YourApp.User do
  use Ecto.Schema

  @required_fields [:first_name, :email]
  @optional_fields [:password]

  schema "users" do
    field(:first_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:encrypted_password, :string)

    has_many(:posts, YourApp.Post)

    timestamps()
  end

  @doc """
  Build a User changeset, adding an error if their password has been pwned
  """
  def changeset(%YourApp.User{} = struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> put_password_hash
  end

  defp put_password_hash(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    with {:ok, password} = Haveibeenpwned.Database.password_pwned?(password) do
      # Password is safe, continue along the happy path
      put_change(changeset, :encrypted_password, ...invoke your crypto...)
    else
      # Password has been previously pwned, invalidate the changeset
      {:warning, pwned_count} -> put_error(changeset, :password, "breached #{pwned_count} times")
      ...match on other paths...
    else
  end
end
```

If you're a Phoenix user, another example might be in your registration 
controller. Bear in mind this a crude example.

```elixir
defmodule YourApp.Web.UserController do
  use YourApp.Web, :controller

  def create(conn, %{"user" => %{"password" => password} = params}) do
    with {:ok, password} = Haveibeenpwned.Database.password_pwned?(password),
         {:ok, %User{}} = Accounts.create_user(params) do
      conn
      |> put_flash(:info, "Registration successful")
      |> redirect(to: "/dashboard")
    else
      {:warning, pwned_count} ->
        conn
        |> put_flash(:error, "Your password has been pwned #{pwned_count} times")
        |> render(:new)
    end
  end
end
```

## Contributing
After forking the [repository on GitHub](https://github.com/team-alembic/haveibeenpwned), 
follow the below steps to get a development copy up and running

```
$ git clone git@github.com:yourusername/haveibeenpwned.git
$ cd haveibeenpwned
$ mix deps.get
```

## Testing
If you're contributing, you can run the test suite with

```
$ mix test
```

## License
This package is available as open source under the [MIT License](https://opensource.org/licenses/MIT)
