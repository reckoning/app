ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require "rails/test_help"
require "minitest/rails"
require 'mocha/mini_test'

require "active_record/fixtures"

class ActionController::TestCase
  include Devise::TestHelpers
  ActiveRecord::Migration.check_pending!
end
