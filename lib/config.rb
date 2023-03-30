require "yaml"

class Config
  def initialize
    @config = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config.yml"))["config"]
  end

  # no trailing slash
  def host
    @config["host"]
  end

  def service_names
    @config["service_names"]
  end

  # lookback_window, days to look back.  0 will look back to midnight today
  def lookback_window
    @config["lookback_window"].to_i
  end
  
  # Potential values:
  #
  # 1.00: exact match only
  # 0.99: separate types per node internal ip
  # 0.95: some alerts are grouped ignoring internal ip/db name but some are separate
  #       this threshold isn't really useful
  # 0.90: grouped types per alert, ignoring internal ip or database name
  def fuzzy_match_threshold
    @config["fuzzy_match_threshold"].to_f
  end
end
