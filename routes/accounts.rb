module Sinatra
  module SampleApp
    module Routing
      module Accounts

        def self.registered(app)

          app.get '/accounts' do
            authenticate_user!

            accounts = settings.application.accounts.map do |account|
              account_id = get_id(account)
              {
                username: account.username,
                email: account.email,
                edit_route: "/accounts/#{account_id}/edit",
                delete_route: "/accounts/#{account_id}",
                manage_group_memberships: "/accounts/#{account_id}/group_memberships",
                deletable: is_admin?
              }
            end

            render_view :accounts, { :accounts => accounts }
          end

          app.get '/accounts/:id/edit' do
            authenticate_user!

            account = settings.client.accounts.get params[:id]

            render_view :accounts_edit, { :account => account }
          end

          app.patch '/accounts/:id' do
            authenticate_user!

            account = settings.client.accounts.get params[:id]
            account.given_name = params[:given_name]
            account.surname = params[:surname]
            account.email = params[:email]
            account.custom_data[:favorite_color] = params[:custom_data][:favorite_color]
            account.save

            flash[:notice] = 'Account edited successfully.'

            redirect '/accounts'
          end

          app.delete '/accounts/:id' do
            authenticate_user!

            account = settings.client.accounts.get params[:id]
            account.delete

            flash[:notice] = 'Account deleted successfully'

            redirect '/accounts'
          end

          app.get '/accounts/new' do
            account = Stormpath::Resource::Account.new({})

            render_view :accounts_new, { :account => account }
          end

          app.post '/accounts' do
            account_params = params.select do |k, v|
              %W[given_name surname email username password].include?(k)
            end

            account = Stormpath::Resource::Account.new account_params

            begin
              account = settings.application.accounts.create account
              account.custom_data[:favorite_color] = params[:custom_data][:favorite_color]
              account.save
              flash[:notice] = 'Your account was created successfully. Depending on directory configuration, you may need to validate account-creation through email.'
              redirect '/session/new'
            rescue Stormpath::Error => error
              flash[:notice] = error.message
              render_view :accounts_new, { :account => account }
            end
          end

        end

      end
    end
  end
end
