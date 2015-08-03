module VoluntaryRecruiting
  module Concerns
    module Model
      module ProjectUser
        module Recruitable
          extend ActiveSupport::Concern
          
          included do
            belongs_to :vacancy
            
            validates :user_id, presence: true, uniqueness: { scope: [:project_id, :vacancy_id] }
            
            attr_accessible :vacancy_id
          end
        end
      end
    end
  end
end