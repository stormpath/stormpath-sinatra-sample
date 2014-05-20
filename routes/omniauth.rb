require 'sinatra/base'

module Sinatra
  module SampleApp
    module Routing
      module Omniauth

        def self.registered(app)
          app.get "/auth/:provider/callback" do
            provider = params[:provider]
            case provider
            when 'facebook'
              access_token = request.env["omniauth.auth"]['credentials']['token']
              request = Stormpath::Provider::FacebookAccountRequest.new(:access_token, access_token)
            when 'google_oauth2'
              access_token = env["omniauth.auth"]["credentials"]["token"]
              request = Stormpath::Provider::GoogleAccountRequest.new(:access_token, access_token)
            end

            result = settings.application.get_provider_account(request)
            if result.is_new_account?
              flash[:notice] = "Welcome to Stormpath Sinatra Sample!"
            else
              flash[:notice] = "Welcome back!"
            end

            account = result.account
            initialize_session account.full_name, account.href
            redirect '/accounts'
          end

          app.get '/auth/failure' do
            flash[:notice] = "Was unable to login."
            render_view :login
          end
        end

      end
    end
  end
end