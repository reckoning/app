ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

if ENV['CODECLIMATE_REPO_TOKEN'].present?
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require "rails/test_help"
require "minitest/rails"
require 'mocha/mini_test'

require "active_record/fixtures"

require 'sidekiq/testing'
Sidekiq::Testing.fake!

# helper
require "support/session_helper"

# rubocop:disable Style/ClassAndModuleChildren
class ActionController::TestCase
  include Devise::TestHelpers
  include SessionHelper
  ActiveRecord::Migration.check_pending!
end
