module Assistants
  class DifyTester
    def self.service_info
      {
        name: 'Dify APIテスト (質問に回答)'
      }
    end

    def self.form_fields
      [
        { name: 'body', label: '質問', type: 'text_area' }
      ]
    end

    def self.generate(params)
      require 'net/http'
      require 'uri'
      require 'json'

      uri = URI.parse(ENV['DIFY_API_ENDPOINT'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request['Authorization'] = "Bearer #{ENV['DIFY_API_KEY']}"
      request['Content-Type'] = 'application/json'

      request_body = {
        inputs: {
          user_prompt: params[:body],
          custom_prompt: 'YES/NOで回答して'
        },
        query: params[:body],
        response_mode: 'blocking',
        user: 'qx'
      }
      request.body = request_body.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        content = result['data']['outputs']['text']
      else
        content = "エラーが発生しました: #{response.code} #{response.message}"
      end

      {
        body: content,
      }
    end
  end
end