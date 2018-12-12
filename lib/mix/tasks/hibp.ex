defmodule Mix.Tasks.Hibp.ConvertTextFile do
  use Mix.Task
  require Logger

  @moduledoc """
  Convert SHA sorted HIBP text file into binary file
  """

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)

  @binary_disk_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @shortdoc "Convert SHA sorted text file into binary format"

  @error_message "please supply abolosute file path to HIBP text file"
  def run([]), do: raise(ArgumentError, @error_message)
  def run([""]), do: raise(ArgumentError, @error_message)

  def run([path]) do
    dest_stream = File.stream!(@binary_disk_path, [{:delayed_write, 10_000_000, 60}])

    path
    |> File.stream!()
    |> Stream.map(&format_line(&1))
    |> Stream.into(dest_stream)
    |> Stream.run()

    Logger.info("Binary HIBP file has been converted in #{@binary_disk_path}")
  end

  def format_line(line) do
    pattern = :binary.compile_pattern(["\n", ":"])
    [sha_str, count_str] = String.split(line, pattern, trim: true)
    {:ok, sha_binary} = Base.decode16(sha_str)
    {count_num, _} = Integer.parse(count_str)
    count_binary = <<count_num::32>>
    sha_binary <> count_binary
  end
end
