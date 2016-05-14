require "algometrics/version"
require "json"
require "logger"

require "algometrics/client"
require "algometrics/middleware/response_handler"

module Algometrics
  SUCCESS = 'success'.freeze
  FAILURE = 'failed'.freeze
end
