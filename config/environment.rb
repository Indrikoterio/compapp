# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# The application.
#config.load_paths << "#{RAILS_ROOT}/app/computer"

require File.join("#{Rails.root}/app/computer", 'computer')