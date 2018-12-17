defmodule Mix.Tasks.Hibp.Text.Download do
  use Mix.Task
  require Logger

  @moduledoc """
  Mix task for downloading Troy Hunt's text database file to the local file
  system

  ## Example usage

  ```
  mix hibp.text.download
  ```

  Once the 7z archive is downloaded, the plain text file is extracted to
  `priv/pwned-passwords-ordered-by-hash.txt`

  By default, this mix task expects the `7z` binary to be available in `$PATH`
  and uses it to extract the plain text file. If you would like to specify
  your own extraction command, use the below config

  ```
  config :haveibeenpwned, decompress_command: "your-command"
  ```

  Once the text database has been downloaded and extracted, you should use
  `mix hibp.text.convert --path /path/to/pwned-passwords-ordered-by-hash.txt`
  to convert it to a binary format.
  """

  @download_url "https://downloads.pwnedpasswords.com/passwords/pwned-passwords-ordered-by-hash.7z"
  @save_path Application.app_dir(:haveibeenpwned, "priv/hibp_text")

  @default_extract_command '7z e #{@save_path} -opriv'
  @extract_command Application.get_env(:haveibeenpwned, :decompress_command) || @default_extract_command

  @doc false
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:download)

    case Download.from(@download_url, path: @save_path, max_file_size: 10_000_000_000) do
      {:ok, path} ->
        Logger.info("Successfully downloaded text database archive to #{path}")
        extract_text_database()
      {:error, :eexist} -> Logger.info("Text database already exists")
      _ -> Logger.error("An unknown error occured while downloading")
    end
  end

  defp extract_text_database do
    Logger.info("Beginning extraction...")
    :os.cmd(@extract_command)
    Logger.info("Finished extraction")
  end
end
