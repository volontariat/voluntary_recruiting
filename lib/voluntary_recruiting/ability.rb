module VoluntaryRecruiting
  class Ability
    def self.after_initialize
      Proc.new do |ability, user, options|
        ability.can :read, [Vacancy, Candidature]
        
        if user.present?
          ability.can [:new, :create], [Vacancy, Candidature]
          ability.can :restful_actions, Vacancy, offeror_id: user.id
          ability.can Vacancy::EVENTS, Vacancy, offeror_id: user.id
          ability.can Candidature::EVENTS, Candidature, offeror_id: user.id
          ability.can :restful_actions, Candidature, resource_type: 'User', resource_id: user.id
        end
      end
    end
  end
end
