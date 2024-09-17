class CreateCreationJob
  include Sidekiq::Worker

  def perform(creation_id, params)
    creation = Creation.find(creation_id)
    
    # AIサービスのフォームデータを取得
    ai_form_data = params['ai_form_data'] || {}
    
    # 評価サービスのフォームデータを取得（存在する場合）
    evaluation_form_data = params['evaluation_form_data'] || {}

    # original_prompt に AIサービスのフォームデータを格納
    creation.original_prompt = ai_form_data

    ai_service = "Assistants::#{creation.assistant_service.camelize}".constantize
    content = ai_service.generate(ai_form_data)
    
    creation.content = content
    creation.content_body = content[:body]

    if creation.evaluation_service.present?
      evaluation_service = "Evaluations::#{creation.evaluation_service.camelize}".constantize
      
      # 評価サービスに渡すパラメータを準備
      evaluation_params = evaluation_form_data.merge(original_text: ai_form_data[:body], content: content)
      
      evaluation = evaluation_service.evaluate(evaluation_params)
      
      creation.evaluation_process = evaluation[:process]
      creation.evaluation_score = evaluation[:score]
      creation.evaluation_comment = evaluation[:comment]
    end

    creation.save
  end
end