module VoluntaryRecruiting
  module Concerns
    module Model
      module Project
        module Recruitable
          extend ActiveSupport::Concern
          
          included do
            has_many :vacancies, dependent: :destroy
          end
        end
      end
    end
  end
end