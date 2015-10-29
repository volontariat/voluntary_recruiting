module StateMachines::Candidature
  def self.included(base)
    base.extend ClassMethods
    
    base.class_eval do
      attr_accessor :current_user
      
      const_set 'STATES', [:new, :accepted, :denied]
      const_set 'EVENTS', [:accept, :deny, :quit]
      
      after_initialize :set_initial_state
      
      state_machine :state, initial: :new do
        event :accept do
          transition [:new, :denied] => :accepted
        end
        
        state :accepted do
          validate :candidatures_limit_not_reached
        end
        
        event :deny do
          transition [:new, :accepted] => :denied
        end
        
        event :quit do
          transition :accepted => :denied
        end
        
        after_transition do |object, transition|
          case transition.to
            when 'accepted'
              if object.vacancy.create_project_user?
                ProjectUser.find_or_create_by_project_id_and_vacancy_id_and_user_id!(
                  project_id: object.vacancy.project_id, vacancy_id: object.vacancy_id, 
                  user_id: object.resource_id
                )
              end
              
              if object.vacancy.limit == object.vacancy.calculate_accepted_candidatures_amount
                object.vacancy.close! unless object.vacancy.closed?
              end
            when 'denied'
              # if comming from :accepted then the vacancy offerer has to reopen the vacancy manually
          end
        end
      end
      
      private
      
      # state validations
      def candidatures_limit_not_reached
        if vacancy.limit == vacancy.calculate_accepted_candidatures_amount
          errors[:state] << I18n.t('activerecord.errors.models.vacancy.attributes.limit.reached')
        end
      end
      
      def set_initial_state
        self.state ||= :new
      end
    end
  end
  
  module ClassMethods
  end
end