lambda_config = YAML.load_file(Rails.root.join('config', 'lambda_functions.yml'), aliases: true)[Rails.env]

Rails.application.config.lambda_function = {
  name: lambda_config['function_name'],
  region: lambda_config['region']
}
