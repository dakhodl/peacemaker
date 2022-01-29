FactoryBot.define do
  factory :peer do
    name { 'John Doe' }
    sequence(:onion_address) { |n| "test-#{n}.onion" }
  end

  factory :ad do
    title { 'Farm fresh eggs' }
    message { 'What else do you need to know' }
    uuid { SecureRandom.uuid }

    trait :blinded do
      messaging_type { :blinded }
    end
  end

  factory :webhook_send, class: Webhook::Send do
    association :resource, factory: :ad
    sequence(:token) { |n| "token-#{n}" }
    uuid { resource.uuid }
    action { :created }
    peer
  end
end
