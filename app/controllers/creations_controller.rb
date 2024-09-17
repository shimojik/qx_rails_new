class CreationsController < ApplicationController
  before_action :authenticate_user!
  def index
    if current_ai_service
      @creations = Creation.where(assistant_service: current_ai_service).order('id DESC')
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

    if @creation.save
      CreateCreationJob.perform_async(@creation.id, params.to_unsafe_h)
      redirect_to @creation, notice: '送信しました。通常10~30秒程度で処理が完了します'
    else
      @ai_services = get_services('Assistants')
      @evaluation_services = get_services('Evaluations')
      @selected_ai_service = @creation.assistant_service
      @selected_evaluation_service = @creation.evaluation_service
      @ai_form_fields = get_form_fields('Assistants', @selected_ai_service)
      @evaluation_form_fields = get_form_fields('Evaluations', @selected_evaluation_service)

      render :new
    end
  end
  private
  def creation_params
    params.require(:creation).permit(:assistant_service, :evaluation_service)
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