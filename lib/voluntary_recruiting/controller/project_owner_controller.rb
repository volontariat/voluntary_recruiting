module VoluntaryRecruiting
  module Controller
    class ProjectOwnerController
      def self.code
        Proc.new do
          @vacancies = {}
          @candidatures = {}
          
          { vacancies: Vacancy::STATES, candidatures: Candidature::STATES }.each do |controller, states|
            query = 'offeror_id = :user_id'
            query += ' OR author_id = :user_id' if controller == :vacancies
            query = "(#{query}) AND state = :state"
            
            states.each do |state|
              # eval("@#{controller}[state] = current_user.offeror_#{controller}.where(state: state).limit(5)")
              collection = controller.to_s.classify.constantize.where(
                query, user_id: current_user.id, state: state
              )
              
              if controller == :vacancies
                collection = collection.where(type: nil)
              elsif controller == :candidatures
                collection = collection.where(resource_type: 'User')
              end
              
              collection.order('created_at DESC').limit(10)
              eval("@#{controller}[state] = collection")
            end
          end
        end  
      end
    end
  end
end