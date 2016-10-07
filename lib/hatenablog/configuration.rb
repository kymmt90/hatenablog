require 'erb'
require 'yaml'
require 'ostruct'

module Hatenablog
  class Configuration < OpenStruct
    OAUTH_CONFIGS = %w(consumer_key consumer_secret access_token access_token_secret user_id blog_id)

    def self.create(config_file)
      config = YAML.load(ERB.new(File.read(config_file)).result)
      unless (lacking_keys = OAUTH_CONFIGS.select {|key| !config.has_key? key}).empty?
        raise ConfigurationError, "Following keys are not setup. #{lacking_keys}"
      end

      new(config)
    end
  end

  class ConfigurationError < StandardError; end
end
