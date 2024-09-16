module Client
  class LangsmithClient
    def initialize
      @endpoint = ENV['LANGSMITH_API_ENDPOINT']
      @api_key = ENV['LANGSMITH_API_KEY']
      @connection = Faraday.new(url: @endpoint) do |faraday|
        faraday.request :json
        faraday.response :json, parser_options: { symbolize_names: true }
        faraday.adapter Faraday.default_adapter
      end
    end

    def create_assistant(graph_id:, config:, metadata: {})
      payload = {
        graph_id: graph_id,
        config: config,
        metadata: metadata
      }

      response = @connection.post('/assistants') do |req|
        req.headers['x-api-key'] = @api_key
        req.body = payload
      end

      handle_response(response)
    end

    def create_thread(metadata: {})
      payload = { metadata: metadata }

      response = @connection.post('/threads') do |req|
        req.headers['x-api-key'] = @api_key
        req.body = payload
      end

      handle_response(response)
    end

    def get_thread_state(thread_id:)
      response = @connection.get("/threads/#{thread_id}/state") do |req|
        req.headers['x-api-key'] = @api_key
      end
    
      handle_response(response)
    end

    def create_run(thread_id:, assistant_id:, question:)
      payload = {
        assistant_id: assistant_id,
        input: {
          messages: [
            { role: "user", content: question }
          ]
        },
        metadata: {
          user: "qx"
        }
      }

      response = @connection.post("/threads/#{thread_id}/runs") do |req|
        req.headers['x-api-key'] = @api_key
        req.body = payload
      end

      handle_response(response)
    end

    def wait_run(thread_id:, run_id:)
      response = @connection.get("/threads/#{thread_id}/runs/#{run_id}/wait") do |req|
        req.headers['x-api-key'] = @api_key
      end

      handle_response(response)
    end

    # def get_run(thread_id:, run_id:)
    #   response = @connection.post("/threads/#{thread_id}/runs/#{run_id}") do |req|
    #     req.headers['x-api-key'] = @api_key
    #   end
  
    #   handle_response(response)
    # end

    def get_run_result(thread_id:, run_id:)
      response = @connection.get("/threads/#{thread_id}/runs/#{run_id}") do |req|
        req.headers['x-api-key'] = @api_key
      end

      handle_response(response)
    end

    def delete_assistant(assistant_id)
      response = @connection.delete("/assistants/#{assistant_id}") do |req|
        req.headers['x-api-key'] = @api_key
      end

      handle_response(response)
    end

    private

    def handle_response(response)
      case response.status
      when 200, 201
        response.body
      when 422
        puts "バリデーションエラー:"
        response.body[:detail].each do |error|
          puts "- #{error[:msg]} (場所: #{error[:loc].join(' -> ')})"
        end
        nil
      else
        puts "エラー: #{response.status}"
        puts JSON.pretty_generate(response.body)
        nil
      end
    end
  end
end