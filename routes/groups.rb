module Sinatra
  module SampleApp
    module Routing
      module Groups
        def self.registered(app)

          app.get '/directories/:directory_url/groups/:group_url' do
            require_logged_in

            directory = settings.client.directories.get CGI.unescape(params[:directory_url])

            group = directory.groups.get CGI.unescape(params[:group_url])

            group_accounts = group.accounts

            group_custom_data = group.custom_data

            render_view :group, { group: group, directory: directory, group_accounts: group_accounts, group_custom_data: group_custom_data }
          end

          app.post '/directories/:directory_url/groups' do
            require_logged_in

            directory = settings.client.directories.get CGI.unescape(params[:directory_url])

            directory.groups.create name: params[:group_name]

            redirect to ("/directories/#{CGI.escape(directory.href)}")
          end

          app.put '/directories/:directory_url/groups/:group_url' do
            require_logged_in

            directory = settings.client.directories.get CGI.unescape(params[:directory_url])

            group = directory.groups.get CGI.unescape(params[:group_url])

            group.custom_data.put("view_classified_info", params[:view_classified_info])
            group.custom_data.put("delete_others", params[:delete_others])
            group.custom_data.save

            redirect to ("/directories/#{CGI.escape(directory.href)}/groups/#{CGI.escape(params[:group_url])}")
          end

        end
      end
    end
  end
end
