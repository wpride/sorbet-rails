# typed: strict
require "rails"
require "sorbet-rails/custom_finder_methods"

class SorbetRails::Railtie < Rails::Railtie
  railtie_name "sorbet-rails"

  rake_tasks do
    path = File.expand_path(__dir__)
    Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
  end

  initializer "sorbet-rails.initialize" do
    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.extend SorbetRails::CustomFinderMethods
      ActiveRecord::Relation.include SorbetRails::CustomFinderMethods

      class ::ActiveRecord::Base
        # open ActiveRecord::Base to override inherited
        class << self
          alias_method :sbr_old_inherited, :inherited

          def inherited(child)
            sbr_old_inherited(child)
            child.send(:public_constant, :ActiveRecord_Relation)
            child.send(:public_constant, :ActiveRecord_AssociationRelation)
            child.send(:public_constant, :ActiveRecord_Associations_CollectionProxy)
          end
        end
      end
    end
  end
end
