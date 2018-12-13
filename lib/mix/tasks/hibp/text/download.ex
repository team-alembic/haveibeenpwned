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

  If the download is succesful, the text database file can be found at
  `priv/hibp_text.txt` relative to your application

  Once downloaded, you should use `mix hibp.text.convert` to convert it to
  a binary format
  """

  @download_url "https://downloads.pwnedpasswords.com/passwords/pwned-passwords-ordered-by-hash.7z"
end
