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
end
