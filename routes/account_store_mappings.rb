module Sinatra
  module SampleApp
    module Routing
      module AccountStoreMappings
        def self.registered(app)

          app.get '/account_store_mappings' do
            require_logged_in
            account_stores = settings.application.account_store_mappings.map(&:account_store)
            directories = settings.client.directories
            render_view :account_store_mappings, { account_stores: account_stores, directories: directories}
          end

          app.post '/account_store_mappings' do
            require_logged_in
            directory = settings.client.directories.get CGI.unescape(params[:href])
            settings.client.account_store_mappings.create(application: settings.application, account_store: directory)
            redirect to ("/account_store_mappings")
          end

          app.delete '/account_store_mappings' do
            require_logged_in
            directory = settings.client.directories.get CGI.unescape(params[:href])
            settings.application.account_store_mappings.each do |account_store_mapping|
               account_store_mapping.delete if account_store_mapping.account_store.href == directory.href
            end
            redirect to ("/account_store_mappings")
          end

        end
      end
    end
  end
end
