module CreationsHelper
  def get_assistant_service_class(service_name)
    "Assistants::#{service_name.camelize}".constantize
  rescue NameError
    nil
  end
end