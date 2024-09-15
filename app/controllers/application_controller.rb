class ApplicationController < ActionController::Base
  helper_method :get_services
  def get_services(namespace)
    Dir[Rails.root.join('app', 'services', namespace.downcase, '*.rb')].map do |f|
      service_name = File.basename(f, '.rb')
      service_class = "#{namespace}::#{service_name.camelize}".constantize
      {
        name: service_name,
        info: service_class.service_info
      }
    end
  end
end
