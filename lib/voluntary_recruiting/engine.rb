module VoluntaryRecruiting
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("../../../app/models/concerns", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/controllers/concerns", __FILE__)
    config.i18n.load_path += Dir[File.expand_path("../../../config/locales/**/*.{rb,yml}", __FILE__)]
    
    config.generators do |g|
      g.orm :active_record
    end
    
    config.to_prepare do
      User.send :include, ::VoluntaryRecruiting::Concerns::Model::User::Recruitable
      ProjectUser.send :include, ::VoluntaryRecruiting::Concerns::Model::ProjectUser::Recruitable
      Project.send :include, ::VoluntaryRecruiting::Concerns::Model::Project::Recruitable
      Voluntary::Navigation::Base.insert_before_core_menu_item :vacancies, :users
      Voluntary::Navigation::Base.add_core_menu_code :vacancies, VoluntaryRecruiting::Navigation.core_menu_codes(:vacancies)
      VoluntaryRecruiting::Navigation.voluntary_menu_customization
      Workflow::ProjectOwnerController.add_tabs_data ['vacancies', 'candidatures'], VoluntaryRecruiting::Controller::ProjectOwnerController.code
      ::Ability.add_after_initialize_callback VoluntaryRecruiting::Ability.after_initialize
    end
  end
end
