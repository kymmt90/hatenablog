require 'erb'
require 'yaml'
require 'ostruct'

module Hatenablog
  class Configuration < OpenStruct
    OAUTH_KEYS = %w(consumer_key consumer_secret access_token access_token_secret user_id blog_id)
    BASIC_KEYS = %w(api_key user_id blog_id)

    # Create a new configuration.
    # @param [String] config_file configuration file path
    # @return [Hatenablog::Configuration]
    def self.create(config_file)
      config = YAML.load(ERB.new(File.read(config_file)).result)
      keys = config['auth_type'] == 'basic' ? BASIC_KEYS : OAUTH_KEYS
      unless (lacking_keys = keys.select {|key| !config.has_key? key}).empty?
        raise ConfigurationError, "Following keys are not setup. #{lacking_keys}"
      end

      new(config)
    end
  end

  class ConfigurationError < StandardError; end
end
