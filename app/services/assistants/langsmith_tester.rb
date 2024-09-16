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

      return { body: 'ランの作成に失敗しました。' } unless run

      result = langsmith_client.get_run_result(
        thread_id: thread[:thread_id],
        run_id: run[:run_id]
      )

      langsmith_client.delete_assistant(assistant[:assistant_id]) if assistant[:assistant_id]

      {
        body: result || 'エラーが発生しました。結果を取得できませんでした。'
      }
    end
  end
end