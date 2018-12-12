defmodule Mix.Tasks.Hibp.Download do
  use Mix.Task
  require Logger

  @moduledoc """
  Download HIBP binary file from S3 bucket
  """

  @binary_download_url Application.get_env(:haveibeenpwned, :binary_download_url) ||
                         "https://s3-ap-southeast-2.amazonaws.com/alembic-hibp/binary"

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)

  @binary_disk_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @shortdoc "download binary version pwned file"
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:download)

    {:ok, stored_file_path} =
      Download.from(
        @binary_download_url,
        path: @binary_disk_path,
        # 13G
        max_file_size: 1024 * 1024 * 1000 * 13
      )

    Logger.info("Binary HIBP file has been downloaded in #{stored_file_path}")
  end
end
