defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)
  @database_read_length 44

  @doc """
  Hashes the supplied binary and returns it as a readable Base16 string
  """
  def hash_binary(binary) when is_binary(binary), do: :crypto.hash(:sha, binary) |> Base.encode16()
  def hash_binary(_), do: raise ArgumentError, "supplied argument must be a valid binary"

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to `@database_read_length`
  """
  def read_portion(offset, length \\ @database_read_length) do
    with {:ok, file} <- :file.open(@database_path, [:binary, :read]),
         {:ok, data} <- :file.pread(file, offset, length) do
      :file.close(file)
      data
    else
      :eof -> {:error, :eof}
      _ -> {:error, :unknown_error}
    end
  end
end
