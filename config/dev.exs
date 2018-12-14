use Mix.Config

# Configure test hash database
config :haveibeenpwned,
  database_relative_path: "priv/hibp_binary"

# Enable verbose logging of database downloads
config :download, verbose_logging: true
