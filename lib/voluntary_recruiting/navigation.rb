module VoluntaryRecruiting
  module Navigation
    def self.voluntary_menu_customization
      {
        organizations: {
          after_resource_has_many: Proc.new do |users, options|
            users.item :candidatures, I18n.t('candidatures.index.title'), user_candidatures_path(@user)
          end
        },
        projects: {
          after_resource_has_many: Proc.new do |project, options|
            project.item :vacancies, I18n.t('vacancies.index.title'), project_vacancies_path(@project) do |vacancy|
              vacancy.item :new, I18n.t('general.new'), new_project_vacancy_path(@project)
            end
          end
        },
        workflow: {
          project_owner_menu_items: Proc.new do |project_owner, options|
            project_owner.item :vacancies, I18n.t('vacancies.index.title'), open_workflow_vacancies_path do |vacancies|
              Vacancy::STATES.each do |state|
                vacancies.item state, I18n.t("vacancies.show.states.#{state}"), eval("#{state}_workflow_vacancies_path")
              end
            end
              
            project_owner.item :candidatures, I18n.t('candidatures.index.title'), new_workflow_candidatures_path do |candidatures|
              Candidature::STATES.each do |state|
                candidatures.item state, I18n.t("candidatures.show.states.#{state}"), eval("#{state}_workflow_candidatures_path")
              end
            end
          end
        },
        authentication: {
          profile_menu_items: Proc.new do |user, options|
            user.item :candidatures, I18n.t('candidatures.index.title'), user_candidatures_path(current_user)
          end
        }
      }.each do |resource, options|
        options.each do |option, value|
          ::Voluntary::Navigation::Base.add_menu_option(resource, option, value)
        end
      end
    end
    
    def self.core_menu_codes(resource)
      case resource
      when :vacancies
        Proc.new do |primary, options|
          primary.item :vacancies, I18n.t('vacancies.index.title'), vacancies_path do |vacancies|
            vacancies.item :new, I18n.t('general.new'), new_vacancy_path
            
            unless (@vacancy.new_record? rescue true)
              vacancies.item :show, "#{@vacancy.name} @ #{@vacancy.project.name}", vacancy_path(@vacancy) do |vacancy|
                
                if can? :destroy, @vacancy
                  vacancy.item :destroy, I18n.t('general.destroy'), vacancy_path(@vacancy), method: :delete, confirm: I18n.t('general.questions.are_you_sure')
                end
                
                vacancy.item :show, I18n.t('general.details'), "#{vacancy_path(@vacancy)}#top"
                vacancy.item :edit, I18n.t('general.edit'), edit_vacancy_path(@vacancy) if can? :edit, @vacancy
                
                vacancy.item :candidatures, I18n.t('candidatures.index.title'), vacancy_candidatures_path(@vacancy) do |candidatures|
                  candidatures.item :new, I18n.t('general.new'), new_vacancy_candidature_path(@vacancy)
                
                  unless (@candidature.new_record? rescue true)
                    candidatures.item(
                      :show, I18n.t('activerecord.models.candidature') + " of #{@candidature.resource.name} @ #{@candidature.vacancy.project.name}", 
                      candidature_path(@candidature) 
                    ) do |candidature|
                      if can? :destroy, @candidature
                        candidature.item :destroy, I18n.t('general.destroy'), candidature_path(@candidature), method: :delete, confirm: I18n.t('general.questions.are_you_sure')
                      end
                      
                      candidature.item :show, I18n.t('general.details'), "#{candidature_path(@candidature)}#top"
                      candidature.item :edit, I18n.t('general.edit'), edit_candidature_path(@candidature) if can? :edit, @candidature
                      
                      candidature.item :comments, I18n.t('comments.index.title'), "#{candidature_path(@candidature)}#comments" do |comments|
                        comments.item(:new, I18n.t('general.new'), new_candidature_comment_path(@candidature)) if @comment
                        
                        if @comment.try(:id) && can?(:edit, @comment)
                          comments.item(:edit, I18n.t('general.edit'), edit_comment_path(@comment))
                        end
                      end 
                    end
                  end
                end
                 
                vacancy.item :comments, I18n.t('comments.index.title'), "#{vacancy_path(@vacancy)}#comments" do |comments|
                  comments.item(:new, I18n.t('general.new'), new_vacancy_comment_path(@vacancy)) if @comment && !@candidature
                  
                  if @comment.try(:id) && can?(:edit, @comment)
                    comments.item(:edit, I18n.t('general.edit'), edit_comment_path(@comment)) 
                  end
                end 
                
                if options[:after_resource_has_many]
                  instance_exec vacancy, {}, &options[:after_resource_has_many]
                end
              end
            end  
          end
        end
      end
    end
  end
end
    