require 'rails_helper'

RSpec.describe User do
  describe 'アソシエーション' do
    it { is_expected.to have_many(:creations) }
    it { is_expected.to have_many(:chat_rooms).dependent(:destroy) }
  end

  describe 'バリデーション' do
    it 'ファクトリが有効であること' do
      expect(build(:user)).to be_valid
    end
  end
end
