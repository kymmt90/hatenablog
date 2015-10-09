require 'yaml'

class Configuration
  # For OAuth authorization.
  attr_reader :consumer_key, :consumer_secret, :access_token, :access_token_secret

  attr_reader :user_id, :blog_id

  # Create a new configuration.
  # @param [String] config_file configuration file path
  # @return [Configuration]
  def initialize(config_file)
    config = YAML.load_file(config_file)
    unless config.has_key?('consumer_key') && config.has_key?('consumer_secret')     &&
           config.has_key?('access_token') && config.has_key?('access_token_secret') &&
           config.has_key?('user_id')      && config.has_key?('blog_id')
      raise ConfigurationError, 'the configure file is incorrect'
    end

    @consumer_key        = config['consumer_key']
    @consumer_secret     = config['consumer_secret']
    @access_token        = config['access_token']
    @access_token_secret = config['access_token_secret']
    @user_id             = config['user_id']
    @blog_id             = config['blog_id']
  end
end

class ConfigurationError < StandardError; end
