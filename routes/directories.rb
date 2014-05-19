module Sinatra
  module SampleApp
    module Routing
      module Directories
        def self.registered(app)
        

          app.get '/directories/:id' do
            require_logged_in

            directory = settings.client.directories.get params[:id]
            directory_groups = directory.groups

            render_view :directory, { directory: directory, directory_groups: directory.groups }
          end



        end
      end
    end
  end
end
