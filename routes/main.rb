require 'sinatra/base'

module Sinatra
  module SampleApp
    module Routing
      module Main

        def self.registered(app)

          app.get '/' do
            if authenticated?
              redirect '/accounts'
            else
              render_view :home
            end
          end

        end

      end
    end
  end
end
