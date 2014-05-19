module Sinatra
  module SampleApp
    module Routing
      module GroupMemberships
        
        def self.registered(app)

          app.get '/accounts/:account_id/group_memberships' do
            require_logged_in

            account = settings.client.accounts.get params[:account_id]
            account_groups = account.groups
            directory_groups = account.directory.groups
            render_view :group_memberships, { account_groups: account_groups, directory_groups: directory_groups, account: account}
          end

          app.post '/accounts/:account_id/group_memberships/:group_id' do
            require_logged_in
            
            account = settings.client.accounts.get params[:account_id]
            group = settings.client.groups.get params[:group_id]

            settings.client.group_memberships.create group: group, account: account

            redirect to ("/accounts/#{params[:account_id]}/group_memberships")
          end

          app.delete '/accounts/:account_id/group_memberships/:group_id' do
            require_logged_in
            
            account = settings.client.accounts.get params[:account_id]
            group = settings.client.groups.get params[:group_id]

            account.group_memberships.each do |group_membership|
              group_membership.delete if group_membership.group.href == group.href
            end

            redirect to ("/accounts/#{params[:account_id]}/group_memberships")
          end

        end

      end
    end
  end
end
