require 'faraday'
require 'uri'

module Algometrics
  class Client
    extend Forwardable

    def_delegators :connection,
                   :get,
                   :post,
                   :head,
                   :put,
                   :delete,
                   :build_url

    DEFAULT_CONFIG = {
      url: "https://algometrics.io",
      api_version: "/v1"
    }

    attr_reader :api_key,
                :url,
                :api_version,
                :adapter

    def initialize(opts = {})
      @api_key = opts[:api_key]

      @api_version = opts[:api_version] || DEFAULT_CONFIG[:api_version]
      @url = URI.join((opts[:url] || DEFAULT_CONFIG[:url]), @api_version).to_s

      @adapter = opts[:adapter] || Faraday.default_adapter
    end

    def connection
      @connection ||= Faraday::Connection.new(
        url: url,
        request: {
          open_timeout: 30,
          timeout: 30
        }
      ) do |f|
        f.adapter adapter
        f.use Algometrics::Middleware::ResponseHandler
      end.tap do |transport|
        transport.headers[:user_agent] = user_agent
        transport.headers[:content_type] = 'application/json'
        transport.headers[:x_api_key] = api_key
      end
    end

    def user_agent
      "algometrics-gem #{Algometrics::VERSION}"
    end

    def track(event:, actor:, status: Algometrics::SUCCESS)
      unless valid_actor?(actor)
        Algometrics::Client.logger.error("Algometrics client error: invalid actor: '#{actor}' " \
                                         "actor type and id must be of the following format: /\\A[\\w\\- ]+\\z/")
        return
      end

      unless valid_event_name?(event)
        Algometrics::Client.logger.error("Algometrics client error: invalid event name: '#{event}' " \
                                         "event name must be of the following format: /\\A[\\w\\- ]+\\z/")
        return
      end

      actor = parse_actor(actor)

      data = {
        event: event,
        actor: actor,
        status: [Algometrics::SUCCESS, Algometrics::FAILURE].include?(status) ? status : Algometrics::SUCCESS
      }

      connection.post("#{api_version}/events", data.to_json)
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end

    private

    def parse_actor(actor)
      case actor
      when String
        type, id = actor.split("#")
        { type: type, id: id }
      when Hash
        actor
      end
    end

    def validate_actor_string(str)
      !(str =~ /\A[\w\- ]+#[\w\- ]+\z/).nil?
    end

    def validate_actor_hash(hash)
      return false unless ([:type, :id] & hash.keys).count > 0
      validate_actor_string("#{hash[:type]}##{hash[:id]}")
    end

    def valid_actor?(actor)
      case actor
      when String
        validate_actor_string(actor)
      when Hash
        validate_actor_hash(actor)
      else
        false
      end
    end

    def valid_event_name?(str)
      !(str =~ /\A[\w\- ]+\z/).nil?
    end
  end
end
