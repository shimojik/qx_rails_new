FactoryBot.define do
  factory :creation do
    association :user
    assistant_service { 'content_generator' }
    evaluation_service { nil }
  end
end
