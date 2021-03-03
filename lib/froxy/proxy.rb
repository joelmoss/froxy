# frozen_string_literal: true

module Froxy
  class Proxy
    def initialize(app)
      @app = app
      @builder = Froxy::Builder.new
    end

    def call(env)
      @builder.attempt(env) || @app.call(env)
    end
  end
end
