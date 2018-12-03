defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)
  @database_read_length 32

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
