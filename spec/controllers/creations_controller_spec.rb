require 'rails_helper'

RSpec.describe CreationsController, type: :controller do
  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #index' do
    before do
      allow(controller).to receive_messages(get_services: [], current_ai_service: 'content_generator')
    end

    it '@creationsが割り当てられること' do
      creation = create(:creation, user: user, assistant_service: 'content_generator')
      get :index
      expect(assigns(:creations)).to include(creation)
    end

    it 'AIサービスが割り当てられること' do
      get :index
      expect(assigns(:ai_services)).to eq([])
    end

    it '評価サービスが割り当てられること' do
      get :index
      expect(assigns(:evaluation_services)).to eq([])
    end

    it '選択されたAIサービスが割り当てられること' do
      get :index
      expect(assigns(:selected_ai_service)).to eq('content_generator')
    end

    it 'indexテンプレートがレンダリングされること' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:creation) { create(:creation, user: user) }

    before do
      allow(controller).to receive_messages(get_services: [], current_ai_service: 'content_generator')
    end

    it '@creationが割り当てられること' do
      get :show, params: { uid: creation.uid }
      expect(assigns(:creation)).to eq(creation)
    end

    it 'AIサービスが割り当てられること' do
      get :show, params: { uid: creation.uid }
      expect(assigns(:ai_services)).to eq([])
    end

    it '選択されたAIサービスが割り当てられること' do
      get :show, params: { uid: creation.uid }
      expect(assigns(:selected_ai_service)).to eq('content_generator')
    end

    it 'showテンプレートがレンダリングされること' do
      get :show, params: { uid: creation.uid }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    before do
      allow(controller).to receive_messages(
        get_services: [],
        current_ai_service: 'content_generator',
        get_form_fields: []
      )
    end

    it '新しいcreationが@creationに割り当てられること' do
      get :new
      expect(assigns(:creation)).to be_a_new(Creation)
    end

    it 'AIサービスが割り当てられること' do
      get :new
      expect(assigns(:ai_services)).to eq([])
    end

    it '評価サービスが割り当てられること' do
      get :new
      expect(assigns(:evaluation_services)).to eq([])
    end

    it '選択されたAIサービスが割り当てられること' do
      get :new
      expect(assigns(:selected_ai_service)).to eq('content_generator')
    end

    it 'AIフォームフィールドが割り当てられること' do
      get :new
      expect(assigns(:ai_form_fields)).to eq([])
    end

    it 'newテンプレートがレンダリングされること' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { { assistant_service: 'content_generator' } }

    before do
      allow(controller).to receive(:get_services).and_return([])
      allow(CreateCreationJob).to receive(:perform_async)
    end

    it '新しいcreationを作成すること' do
      expect do
        post :create, params: { creation: valid_attributes }
      end.to change(Creation, :count).by(1)
    end

    it '現在のユーザーをcreationに割り当てること' do
      post :create, params: { creation: valid_attributes }
      expect(Creation.last.user).to eq(user)
    end

    it 'CreateCreationJobをエンキューすること' do
      post :create, params: { creation: valid_attributes }
      expect(CreateCreationJob).to have_received(:perform_async).with(Creation.last.id, anything)
    end

    it '作成されたcreationにリダイレクトすること' do
      post :create, params: { creation: valid_attributes }
      expect(response).to redirect_to(Creation.last)
    end

    context 'when 無効なパラメータの場合' do
      let(:creation_instance) { instance_double(Creation, save: false) }

      before do
        allow(Creation).to receive(:new).and_return(creation_instance)
        allow(controller).to receive(:get_form_fields).and_return([])
      end

      it '新しいcreationを作成しないこと' do
        expect do
          post :create, params: { creation: { assistant_service: nil } }
        end.not_to change(Creation, :count)
      end

      it 'newテンプレートをレンダリングすること' do
        post :create, params: { creation: { assistant_service: nil } }
        expect(response).to render_template(:new)
      end
    end
  end
end
