defmodule Mix.Tasks.Hibp.Text.Convert do
  use Mix.Task
  require Logger

  @moduledoc """
  Mix task for converting Troy Hunt's text database in to a binary format
  which is readable by this package. This task expects the text database to
  exist on the local file system

  Even though we are in Elixir land, we're unable to convert the file
  asynchronously with Flow given ordering matters.

  You must tell the task where the text database file exists with the
  `--path` argument

  ## Example usage

  ```
  mix hibp.text.convert --path /absolute/path/hibp_database.text
  ```

  The resultant binary fire will be saved to the default binary file path,
  which is `priv/hibp_binary` relative to your application. If you wish to
  provide a different path, you can do so with application config

  ```
  config :haveibeenpwned, database_relative_path: "/your/path/hibp_binary"
  ```
  """

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @binary_disk_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  defp empty_message do
    raise(ArgumentError, "Please supply an absolute path to the HIBP text database file")
  end

  def run([]), do: empty_message()
  def run([""]), do: empty_message()

  def run([path]) do
    dest_stream = File.stream!(@binary_disk_path, [{:delayed_write, 10_000_000, 60}])

    path
    |> File.stream!()
    |> Stream.map(&format_line(&1))
    |> Stream.into(dest_stream)
    |> Stream.run()

    Logger.info(
      "Finished converting text database. Binary version can be found at #{@binary_disk_path}"
    )
  end

  defp format_line(line) do
    pattern = :binary.compile_pattern(["\n", ":"])
    [sha_str, count_str] = String.split(line, pattern, trim: true)
    {:ok, sha_binary} = Base.decode16(sha_str)
    {count_num, _} = Integer.parse(count_str)
    count_binary = <<count_num::32>>
    sha_binary <> count_binary
  end
end
