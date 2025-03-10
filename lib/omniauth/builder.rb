module OmniAuth
  class Builder
    def initialize app, &block
      @app = AuthBuilder.app(app, &block)
    end

    def call env
      @app.call(env)
    end
  end
end
