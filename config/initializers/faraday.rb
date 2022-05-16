# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "faraday/net_http"
Faraday.default_adapter = :net_http
