require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room, user: user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #show' do
    it '@chat_roomが割り当てられること' do
      get :show, params: { uid: chat_room.uid }
      expect(assigns(:chat_room)).to eq(chat_room)
    end

    it '@messagesが割り当てられること' do
      message = create(:message, chat_room: chat_room)
      get :show, params: { uid: chat_room.uid }
      expect(assigns(:messages)).to include(message)
    end

    it '新しいメッセージが@messageに割り当てられること' do
      get :show, params: { uid: chat_room.uid }
      expect(assigns(:message)).to be_a_new(Message)
    end

    it 'ユーザーが所有者でない場合はリダイレクトすること' do
      other_user = create(:user)
      other_chat_room = create(:chat_room, user: other_user)
      get :show, params: { uid: other_chat_room.uid }
      expect(response).to redirect_to(root_path)
    end

    it 'ユーザーが所有者でない場合はアラートを表示すること' do
      other_user = create(:user)
      other_chat_room = create(:chat_room, user: other_user)
      get :show, params: { uid: other_chat_room.uid }
      expect(flash[:alert]).to be_present
    end
  end

  describe 'POST #create' do
    it '新しいチャットルームを作成すること' do
      expect do
        post :create
      end.to change(ChatRoom, :count).by(1)
    end

    it '新しいチャットルームにリダイレクトすること' do
      post :create
      expect(response).to redirect_to(chat_path(ChatRoom.last.uid))
    end

    it '現在のユーザーを所有者として設定すること' do
      post :create
      expect(ChatRoom.last.user).to eq(user)
    end

    context 'when チャットルームの保存に失敗した場合' do
      let(:chat_room_instance) { instance_double(ChatRoom, save: false) }

      before do
        allow(ChatRoom).to receive(:new).and_return(chat_room_instance)
      end

      it 'root_pathにリダイレクトすること' do
        post :create
        expect(response).to redirect_to(root_path)
      end

      it 'アラートを表示すること' do
        post :create
        expect(flash[:alert]).to be_present
      end
    end
  end
end
