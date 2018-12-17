# Have I Been Pwned?
[![Build status](https://badge.buildkite.com/0fd47b708e0e4e4a9af17bb8986598c3ddc0b937037443d2a6.svg)](https://buildkite.com/alembic/have-i-been-pwned)
[![Hex.pm](https://img.shields.io/hexpm/v/haveibeenpwned.svg?maxAge=2592000)](https://hex.pm/packages/haveibeenpwned)
[![License: MIT](https://img.shields.io/github/license/team-alembic/haveibeenpwned.svg)](https://opensource.org/licenses/MIT)


An Elixir hex package allowing developers to check if a new user password has 
been pwned, as indicated by Troy Hunt's [Have I Been Pwned?](https://haveibeenpwned.com/)

This package is designed to be deployed with your own binary searchable HIBP
database. It does not communicate with the HIBP API. If you wish to use the 
HIBP API, you should [take a look at this package instead](https://github.com/thiamsantos/pwned).

If you would rather deploy your own database file and stay on your own network
without having to rely on connectivity of a third party service, read on!

## Introduction

We do not use the HIBP API to check passwords, this package takes a different 
approach. Instead, we provide a downloadable binary file which is binary 
searched near instantaneously at runtime. We provide a mix task to download 
the file, which is ~7.2GB in size.

You can also download your own database file if you do not wish to use the one 
we provide. See examples below in the Tasks section.

This approach may not work for all deployment scenarios, so please consider 
if this package is right for you.

## Why?

If your deployment scenario allows it, we believe this to be a powerful
approach as it can be applied within your own network without being dependent
on the uptime of or connectivity to a third party service.

## Installation

Add the `:haveibeenpwned` app to your dependencies in `mix.exs`

```elixir
def deps do
  [
    {:haveibeenpwned, "~> 0.1.0"}
  ]
end
```

## Setup - Using the provided binary database

If you're happy to use the binary database we provide, setup is only a single
step. You can use the `mix hibp.download` mix task to download it, and it will
be saved in the correct location.

```bash
$ mix hibp.download
```

The provided database is ~7.2GB in size and hosted in an S3 bucket located in Sydney,
Australia.

## Setup - Using your own binary database

If you would prefer to use your own binary database for security reasons, that's
fine too! We provide some config and mix tasks to make this easy.

NOTE: If you have previously generated your own binary, you don't need to
generate it every time. You can simply use the `mix hibp.download` mix task
and point it at your own binary via the following config

```
config :haveibeenpwned, binary_download_url: "https://your-binary.com/binary"
```

Once you run `mix hibp.download`, your own binary will be downloaded instead of
the binary we provide.

#### 1. Download text database

You can download the text database via the following mix task

```
mix hibp.text.download
```

This will download a 7z archive containing Troy Hunt's database, and extract
the archive to plain text. The result is a `pwned-passwords-ordered-by-bash.txt`
file location in `priv` by default.

#### 2. Convert text database to binary

The next step is to convert the plain text database to a binary format. You can
do this via another mix task

```
mix hibp.text.convert --path /path/to/pwned-passwords-ordered-by-hash.txt
```

NOTE: It is recommend you do this once, or whenever Troy Hunt releases a new
version of the database. You should upload your binary to the internet or your
intranet, and use the `mix hibp.download` task to download your own binary.

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

## Anout database

Binary database is converted from SHA-1 Version 3(ordered by hash) text file(22.79GB)
into binary file(12.41GB). By truncating SHAs in half, the file size have been decreased
further(7.2GB). It will increate the chance of a false positive by a very small margin,
but will never produce a false negative result.

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
