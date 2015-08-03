module VoluntaryRecruiting
  module Concerns
    module Model
      module User
        module Recruitable
          extend ActiveSupport::Concern
          
          included do
            has_many :offeror_vacancies, source: :offeror, class_name: 'Vacancy'
            has_many :offeror_candidatures, source: :offeror, class_name: 'Candidature'
            has_many :candidatures, as: :resource
          end
        end
      end
    end
  end
end