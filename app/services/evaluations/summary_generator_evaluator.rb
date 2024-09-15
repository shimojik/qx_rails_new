module Evaluations
  class SummaryGeneratorEvaluator
    def self.form_fields
      [
        { name: 'ideal_summary', label: '理想的な要約（あれば）', type: 'text_area' },
        { name: 'key_elements', label: '要約に含めるべき要素', type: 'text_area' }
      ]
    end

    def self.service_info
      {
        name: '要約評価 (生成された要約を評価します)'
      }
    end

    def self.evaluate(params)
      content = params[:content]
      ideal_summary = params[:ideal_summary]
      key_elements = params[:key_elements]

      llm = Langchain::LLM::Anthropic.new(
        api_key: ENV['ANTHROPIC_API_KEY'],
        default_options: {
          chat_completion_model_name: 'claude-3-sonnet-20240229',
          max_tokens_to_sample: 1000,
          temperature: 0.7
        }
      )

      template = <<~TEMPLATE
        以下の{元のテキスト}に対する要約の品質を評価してください。

        <元のテキスト>
        {original_text}
        </元のテキスト>

        <生成された要約>
        {summary}
        </生成された要約>

        #{ideal_summary ? "<理想的な要約の例>\n#{ideal_summary}\n</理想的な要約の例>\n" : ''}
        #{key_elements ? "<要約に含めるべき要素>\n#{key_elements}\n</要約に含めるべき要素>\n" : ''}

        <評価基準>
        1. 元の文章の情報のみで構成されているか（新たな情報が加わっていないか）
        2. 文章として成り立っているか
        3. 元の文章のにおける重要な要素が全て含まれているか
        </評価基準>

        評価結果を以下のJSON形式で出力してください：
        {
          "process": "評価プロセスの詳細をここに記述",
          "score": 0から100までの整数値,
          "comment": "評価コメントをここに記述(特に減点基準を中心に出来るだけ詳細に説明してください)"
        }

        * jsonや```のような記号を含め前後に何も入れず直接結果のみを出力してください
      TEMPLATE

      assistant = Langchain::Assistant.new(
        llm: llm,
        instructions: template,
        tools: []
      )

      assistant.add_message_and_run(content: {
        original_text: content[:original_text],
        summary: content[:body]
      })

      messages = assistant.messages
      result = JSON.parse(messages.last.content)

      p '-----------'
      p result

      {
        process: result['process'],
        score: result['score'],
        comment: result['comment']
      }
    end
  end
end