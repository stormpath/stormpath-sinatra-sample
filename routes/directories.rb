module Sinatra
  module SampleApp
    module Routing
      module Directories
        def self.registered(app)
        

          app.get '/directories/:directory_url' do
            require_logged_in

            directory = settings.client.directories.get CGI.unescape(params[:directory_url])
            directory_groups = directory.groups

            render_view :directory, { directory: directory, directory_groups: directory.groups }
          end



        end
      end
    end
  end
end
