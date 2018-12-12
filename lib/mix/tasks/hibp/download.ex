defmodule Mix.Tasks.Hibp.Download do
  use Mix.Task
  require Logger

  @moduledoc """
  Mix task for downloading a HIBP binary database file. You can download the
  provided binary database file from Alembic's S3 bucket, or you can specify
  your own download address

  If you wish to download the Alembic provided binary database, no configuration
  is required. If you wish to download your own binary database, you need to
  specify a URL via the following application config option.

  ```
  config :haveibeenpwned, binary_download_url: "https://your-url.com/binary_file"
  ```
  """

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)

  @binary_default_download_url "https://s3-ap-southeast-2.amazonaws.com/alembic-hibp/binary"
  @binary_download_url Application.get_env(:haveibeenpwned, :binary_download_url)
  @binary_disk_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:download)

    case Download.from(@binary_download_url || @binary_default_download_url,
           path: @binary_disk_path,
           max_file_size: 13_631_488_000
         ) do
      {:ok, path} -> Logger.info("Successfully downloaded to #{path}")
      {:error, :eexist} -> Logger.info("Binary already exists")
      _ -> Logger.error("An error occured when downloading")
    end
  end
end
