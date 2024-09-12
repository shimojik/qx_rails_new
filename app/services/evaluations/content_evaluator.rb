module Evaluations
  class ContentEvaluator
    def self.form_fields
      [
        { name: 'criteria', label: '評価基準', type: 'text_area', default: '簡潔さ、正確さ、読みやすさ' }
      ]
    end

    def self.service_info
      {
        name: 'コンテンツ評価 (生成されたコンテンツを評価します)'
      }
    end

    def self.evaluate(params)
      content = params[:content]
      criteria = params[:criteria]

      llm = Langchain::LLM::Anthropic.new(
        api_key: ENV['ANTHROPIC_API_KEY'],
        model_name: 'claude-3-sonnet-20240229',
        max_tokens: 300,
        temperature: 0.7
      )

      template = <<~TEMPLATE
        以下の文章を、指定された評価基準に基づいて評価してください。
        評価基準: {criteria}

        評価対象の文章:
        {content}

        評価プロセス:
        評価スコア（0-100）:
        評価コメント:
      TEMPLATE

      prompt = Langchain::Prompt::PromptTemplate.new(
        template: template,
        input_variables: ['criteria', 'content']
      )

      chain = Langchain::Chain::LLMChain.new(llm: llm, prompt: prompt)

      result = chain.call({ criteria: criteria, content: content[:summary] })

      {
        process: result['text'].split("\n評価スコア")[0],
        score: result['text'].split("\n評価スコア")[1].split("\n")[0].to_i,
        comment: result['text'].split("\n評価コメント:")[1].strip
      }
    end
  end
end