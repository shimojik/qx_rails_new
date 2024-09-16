module Assistants
  class ContentGenerator
    def self.service_info
      {
        name: 'コンテンツ生成 (テキストからコンテンツを生成)'
      }
    end

    def self.form_fields
      [
        { name: 'body', label: '元テキスト', type: 'text_area' }
      ]
    end

    def self.generate(params)
      llm = Langchain::LLM::Anthropic.new(
        api_key: ENV['ANTHROPIC_API_KEY'],
        default_options: {
          chat_completion_model_name: 'claude-3-sonnet-20240229',
          temperature: 0.7
        }
      )

      template = <<~TEMPLATE
        あなたは優秀なコンテンツ作成者です。与えられた文章を元に、新しいコンテンツを生成してください。
        元の意味を保持しつつ、創造的で興味深いコンテンツを作成することが目標です。
        最大文字数は#{params[:max_length]}文字です。
        * jsonや```のような記号を含め前後に何も入れず直接結果のみを出力してください

        文章：
        {text}

        生成されたコンテンツ：
      TEMPLATE

      assistant = Langchain::Assistant.new(
        llm: llm,
        instructions: template,
        tools: []
      )

      assistant.add_message_and_run(content: params[:body])

      messages = assistant.messages
      content = messages.last.content

      {
        body: content,
      }
    end
  end
end