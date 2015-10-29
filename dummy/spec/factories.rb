def r_str
  SecureRandom.hex(3)
end

def resource_has_many(resource, association_name)
  association = if resource.send(association_name).length > 0
    nil
  elsif association_name.to_s.classify.constantize.count > 0
    association_name.to_s.classify.constantize.last
  else
    Factory.create association_name.to_s.singularize.to_sym
  end
  
  resource.send(association_name).send('<<', association) if association
end

FactoryGirl.define do
  Voluntary::Test::RspecHelpers::Factories.code.call(self)
  
  factory :vacancy do
    association :project
    sequence(:name) { |n| "vacancy #{n}" }
    text Faker::Lorem.sentences(20).join(' ')
    limit 1
    state 'open'
    resource_type 'User'
  end
  
  factory :candidature do
    association :resource, factory: :user
    association :vacancy
    sequence(:name) { |n| "candidature #{n}" }
    text Faker::Lorem.sentences(20).join(' ')
  end
end