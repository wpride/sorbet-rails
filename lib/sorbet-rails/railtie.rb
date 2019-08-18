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
    end

    # in test & dev, the models are not pre-loaded, we need to load them manually
    Rails.application.eager_load! unless Rails.env.production?
    ActiveRecord::Base.descendants.each do |model|
      model.send(:public_constant, :ActiveRecord_Relation)
      model.send(:public_constant, :ActiveRecord_AssociationRelation)
      model.send(:public_constant, :ActiveRecord_Associations_CollectionProxy)
    end
  end
end
