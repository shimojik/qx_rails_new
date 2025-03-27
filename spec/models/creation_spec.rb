require 'rails_helper'

RSpec.describe Creation do
  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'ミックスイン' do
    it 'UidModuleをインクルードしていること' do
      expect(described_class.included_modules).to include(UidModule)
    end
  end
end
