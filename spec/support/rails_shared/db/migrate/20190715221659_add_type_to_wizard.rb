class AddTypeToWizard < ActiveRecord::Migration["#{ENV['RAILS_VERSION']}" || "5.2"]
  def change
    add_column :wizards, :type, :string, null: false, default: 'Wizard'
  end
end
