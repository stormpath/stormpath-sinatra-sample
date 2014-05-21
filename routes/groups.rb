module Sinatra
  module SampleApp
    module Routing
      module Groups
        def self.registered(app)

          app.get '/directories/:directory_id/groups/:group_id' do
            authenticate_user!

            directory = settings.client.directories.get params[:directory_id]

            group = settings.client.groups.get params[:group_id]

            group_accounts = group.accounts

            group_custom_data = group.custom_data

            render_view :group, { group: group, directory: directory, group_accounts: group_accounts, group_custom_data: group_custom_data }
          end

          app.post '/directories/:directory_id/groups' do
            authenticate_user!

            directory = settings.client.directories.get params[:directory_id]

            settings.client.groups.create name: params[:group_name]

            redirect to ("/directories/#{params[:directory_id]}")
          end

          app.put '/directories/:directory_id/groups/:group_id' do
            authenticate_user!

            directory = settings.client.directories.get params[:directory_id]

            group = settings.client.groups.get params[:group_id]

            group.custom_data["view_classified_info"] = params[:view_classified_info]
            group.custom_data["delete_others"] = params[:delete_others]
            group.custom_data.save

            redirect to ("/directories/#{params[:directory_id]}/groups/#{params[:group_id]}")
          end

        end
      end
    end
  end
end
