require 'sinatra/base'

module Sinatra
  module SampleApp
    module Routing
      module Omniauth

        def self.registered(app)
          app.get "/auth/:provider/callback" do

            provider = if params[:provider] == 'facebook'
              'facebook'
            else
              'google'
            end

            access_token = env["omniauth.auth"]['credentials']['token']

            request = Stormpath::Provider::AccountRequest.new(provider, :access_token, access_token)
            result = settings.application.get_provider_account(request)

            flash[:notice] = if result.is_new_account?
              "Welcome to Stormpath Sinatra Sample!"
            else
              "Welcome back!"
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