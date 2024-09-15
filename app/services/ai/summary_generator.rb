module Ai
  class SummaryGenerator
    def self.service_info
      {
        name: '要約生成 (テキストを要約)'
      }
    end

    def self.form_fields
      [
        { name: 'body', label: '元テキスト', type: 'text_area' },
        { name: 'max_length', label: '最大文字数', type: 'number', default: 300 }
      ]
    end

    def self.generate(params)
      llm = Langchain::LLM::Anthropic.new(
        api_key: ENV['ANTHROPIC_API_KEY'],
        default_options: {
          chat_completion_model_name: 'claude-3-sonnet-20240229',
          max_tokens_to_sample: params[:max_length].to_i,
          temperature: 0.7
        }
      )

      template = <<~TEMPLATE
        あなたは優秀な要約者です。与えられた文章を簡潔に要約してください。
        元の意味を保持しつつ、できるだけ短く要約することが目標です。
        最大文字数は#{params[:max_length]}文字です。
        * jsonや```のような記号を含め前後に何も入れず直接結果のみを出力してください

        文章：
        {text}

        要約：
      TEMPLATE

      assistant = Langchain::Assistant.new(
        llm: llm,
        instructions: template,
        tools: []
      )

      assistant.add_message_and_run(content: params[:body])

      messages = assistant.messages
      summary = messages.last.content

      {
        body: summary,
      }
    end
  end
end