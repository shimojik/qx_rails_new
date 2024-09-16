class CreationsController < ApplicationController
  before_action :authenticate_user!
  def index
    if current_ai_service
      @creations = Creation.where(content_service: current_ai_service).order('id DESC')
    else
      @creations = Creation.order('id DESC')
    end
    @ai_services = get_services('Assistants')
    @evaluation_services = get_services('Evaluations')
    @selected_ai_service = current_ai_service
    @selected_evaluation_service = params[:ev]

    render_custom_view(:index)
  end

  def show
    @creation = Creation.find_by(uid: params[:uid])
    @ai_services = get_services('Assistants')
    @selected_ai_service = current_ai_service
    render_custom_view(:show)
  end

  def new
    @creation = Creation.new
    @ai_services = get_services('Assistants')
    @evaluation_services = get_services('Evaluations')
    @selected_ai_service = current_ai_service
    @selected_evaluation_service = params[:ev]
    @ai_form_fields = get_form_fields('Assistants', @selected_ai_service) if @selected_ai_service
    @evaluation_form_fields = get_form_fields('Evaluations', @selected_evaluation_service) if @selected_evaluation_service

    render_custom_view(:new)
  end

  def create
    @creation = Creation.new(creation_params)
    @creation.user = current_user

    @selected_ai_service = current_ai_service
    @selected_evaluation_service = @creation.evaluation_service

    # AIサービスのフォームデータを取得
    ai_form_data = params[:ai_form_data] || {}
    
    # 評価サービスのフォームデータを取得（存在する場合）
    evaluation_form_data = params[:evaluation_form_data] || {}

    # original_prompt に AIサービスのフォームデータを格納
    @creation.original_prompt = ai_form_data

    ai_service = "Assistants::#{@creation.content_service.camelize}".constantize
    content = ai_service.generate(ai_form_data)
    
    @creation.content = content
    @creation.content_body = content[:body] # または適切なキーを使用

    if @creation.evaluation_service.present?
      evaluation_service = "Evaluations::#{@creation.evaluation_service.camelize}".constantize
      
      # 評価サービスに渡すパラメータを準備
      evaluation_params = evaluation_form_data.merge(original_text: ai_form_data[:body], content: content)
      
      evaluation = evaluation_service.evaluate(evaluation_params)
      
      @creation.evaluation_process = evaluation[:process]
      @creation.evaluation_score = evaluation[:score]
      @creation.evaluation_comment = evaluation[:comment]
    end

    if @creation.save
      redirect_to @creation, notice: 'Content was successfully generated and evaluated.'
    else
      @ai_services = get_services('Assistants')
      @evaluation_services = get_services('Evaluations')
      @selected_ai_service = @creation.content_service
      @selected_evaluation_service = @creation.evaluation_service
      @ai_form_fields = get_form_fields('Assistants', @selected_ai_service)
      @evaluation_form_fields = get_form_fields('Evaluations', @selected_evaluation_service)

      render :new
    end
  end
  private
  def creation_params
    params.require(:creation).permit(:content_service, :evaluation_service)
  end

  def ai_form_params
    params.require(:ai_form_data).permit! if params[:ai_form_data]
  end

  def evaluation_form_params
    params.require(:evaluation_form_data).permit! if params[:evaluation_form_data]
  end

  def get_form_fields(namespace, service_name)
    return nil unless service_name
    "#{namespace}::#{service_name.camelize}".constantize.form_fields rescue nil
  end

  def render_custom_view(default_view)
    custom_view = "creations/#{@selected_ai_service}/#{default_view}"
    if template_exists = lookup_context.template_exists?(custom_view, [], false)
      render custom_view
    else
      render default_view
    end
  end
end