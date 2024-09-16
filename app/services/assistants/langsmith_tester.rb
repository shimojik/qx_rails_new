module Assistants
  class LangsmithTester
    def self.service_info
      {
        name: 'Langsmith APIテスト (質問に回答)'
      }
    end

    def self.form_fields
      [
        { name: 'body', label: '質問', type: 'text_area' }
      ]
    end

    def self.generate(params)
      langsmith_client = Client::LangsmithClient.new

      assistant = langsmith_client.create_assistant(
        graph_id: 'agent',
        config: {
        }
      )

      return { body: 'アシスタントの作成に失敗しました。' } unless assistant

      thread = langsmith_client.create_thread

      return { body: 'スレッドの作成に失敗しました。' } unless thread

      run = langsmith_client.create_run(
        thread_id: thread[:thread_id],
        assistant_id: assistant[:assistant_id],
        question: params[:body]
      )


      wait_result = nil
      start_time = Time.now
      loop do
        wait_result = langsmith_client.get_run_result(
          thread_id: thread[:thread_id],
          run_id: run[:run_id]
        )
        if wait_result[:status] == 'success'
          break
        elsif Time.now - start_time > 20
          return false
        end
        sleep 2
      end

      thread_state = langsmith_client.get_thread_state(thread_id: thread[:thread_id])
      if thread_state
        if thread_state[:values] && thread_state[:values][:messages] #&& thread_state[:values][:messages].last && thread_state[:values][:messages].last[:content] && thread_state[:values][:messages].last[:content].first && thread_state[:values][:messages].last[:content].first[:text]
          messages = thread_state[:values][:messages]
          result = messages.select { |msg| msg[:type] == 'ai' }.each_with_index.map { |msg, index| "#{msg[:content][0][:text]}" }.join("\n")
        else
          result = 'スレッドの状態にメッセージが含まれていません。'
        end
      else
        result = 'スレッドの状態の取得に失敗しました。'
      end

      langsmith_client.delete_assistant(assistant[:assistant_id]) if assistant[:assistant_id]

      {
        body: result || 'エラーが発生しました。結果を取得できませんでした。'
      }
    end
  end
end