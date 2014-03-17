module Sinatra
  module SampleApp
    module Routing
      module GroupMemberships
        
        def self.registered(app)

          app.get '/accounts/:account_url/group_memberships' do
            require_logged_in

            account = settings.client.accounts.get CGI.unescape(params[:account_url])
            account_groups = account.groups
            directory_groups = account.directory.groups
            render_view :group_memberships, { account_groups: account_groups, directory_groups: directory_groups, account: account}
          end

          app.post '/accounts/:account_url/group_memberships/:group_url' do
            require_logged_in
            
            group = settings.application.groups.get CGI.unescape(params[:group_url])
            account = settings.client.accounts.get CGI.unescape(params[:account_url])

            settings.client.group_memberships.create group: group, account: account

            redirect to ("/accounts/#{CGI.escape(params[:account_url])}/group_memberships")
          end

          app.delete '/accounts/:account_url/group_memberships/:group_url' do
            require_logged_in
            
            group = settings.application.groups.get CGI.unescape(params[:group_url])
            account = settings.client.accounts.get CGI.unescape(params[:account_url])

            account.group_memberships.each do |group_membership|
              group_membership.delete if group_membership.group.href == group.href
            end

            redirect to ("/accounts/#{CGI.escape(params[:account_url])}/group_memberships")
          end

        end

      end
    end
  end
end
