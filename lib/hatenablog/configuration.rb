require 'erb'
require 'yaml'
require 'ostruct'

module Hatenablog
  class Configuration < OpenStruct
    # @dynamic auth_type, consumer_key, consumer_secret, access_token, access_token_secret, api_key, user_id, blog_id

    OAUTH_KEYS = %i(consumer_key consumer_secret access_token access_token_secret user_id blog_id)
    BASIC_KEYS = %i(api_key user_id blog_id)

    # Create a new configuration.
    # @param [String] config_file configuration file path
    # @return [Hatenablog::Configuration]
    def self.create(config_file)
      loaded_config = YAML.load(ERB.new(File.read(config_file)).result)
      config = new(loaded_config)
      config.check_valid_or_raise
    end

    def check_valid_or_raise
      unless (lacking_keys = self.send(:lacking_keys)).empty?
        raise ConfigurationError, "Following keys are not setup. #{lacking_keys.map(&:to_s)}"
      end
      self
    end

    private

    def lacking_keys
      required_keys = self['auth_type'] == 'basic' ? BASIC_KEYS : OAUTH_KEYS
      config_keys   = to_h.keys
      required_keys.select { |key| !config_keys.include?(key) }
    end
  end

  class ConfigurationError < StandardError; end
end
