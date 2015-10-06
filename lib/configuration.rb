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
    @consumer_key        = config['consumer_key']
    @consumer_secret     = config['consumer_secret']
    @access_token        = config['access_token']
    @access_token_secret = config['access_token_secret']
    @user_id             = config['user_id']
    @blog_id             = config['blog_id']
  end
end
