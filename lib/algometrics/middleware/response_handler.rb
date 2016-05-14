module Algometrics
  module Middleware
    class ResponseHandler < Faraday::Middleware

      def call(request_env)
        @app.call(request_env).on_complete do |response_env|
          status = response_env.status

          case status
          when 401
            Algometrics::Client.logger.error('Invalid Algometrics API key')
          end
        end
      end

    end # class ResponseHandler
  end # module Middleware
end # module Algometrics
