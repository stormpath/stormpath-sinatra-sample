require 'sinatra/base'

module Sinatra
  module SampleApp
    module Helpers

      ADMIN_GROUP_NAME = 'admin'

      def render_view(view, locals={})
        locals = { :session => session }.merge locals
        erb view, :layout => true, :locals => locals
      end

      def require_logged_in()
        redirect('/session/new') unless is_authenticated?
      end

      def require_logged_out()
        redirect('/accounts') if is_authenticated?
      end

      def is_authenticated?()
        return !!session[:stormpath_account_url]
      end

      def initialize_session(display_name, stormpath_account_url)
        session[:display_name] = display_name
        session[:stormpath_account_url] = stormpath_account_url
      end

      def destroy_session()
        session.delete(:display_name)
        session.delete(:stormpath_account_url)
        @is_admin = false
      end

      def is_admin?()
        if not @is_admin
          account = settings.client.accounts.get(session[:stormpath_account_url])
          @is_admin = account.groups.any? do |group|
            group.name == ADMIN_GROUP_NAME
          end
        end

        @is_admin
      end

      def href_for_account_store(account_store)
        if account_store.class == Stormpath::Resource::Directory
          "/directories/#{CGI.escape(account_store.href)}"
        else
          "/directories/#{CGI.escape(account_store.directory.href)}/groups/#{CGI.escape(account_store.href)}"
        end
      end

      def account_store_type(account_store)
        if account_store.class == Stormpath::Resource::Directory
          "Directory"
        else
          "Group"
        end
      end

      def can_delete_others
        if session[:stormpath_account_url]
          account = settings.client.accounts.get(session[:stormpath_account_url])
          return account.groups.any? { |group| group.custom_data.get('delete_others') == "true" }
        end
      end

    end
  end
end
