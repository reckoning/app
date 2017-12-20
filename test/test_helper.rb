# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'simplecov-html'

formatters = [
  SimpleCov::Formatter::Console,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)
SimpleCov.start('rails')

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require "rails/test_help"
require "minitest/rails"

require "active_record/fixtures"
require "database_cleaner"

require "faker"

require 'sidekiq/testing'
Sidekiq::Testing.fake!

# helper
require "support/session_helper"

# database cleaner
DatabaseCleaner.strategy = :transaction

# rubocop:disable Style/ClassAndModuleChildren
class ActionController::TestCase
  fixtures :all
  include Devise::Test::ControllerHelpers
  include SessionHelper
  ActiveRecord::Migration.check_pending!

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end

class ActionView::TestCase
  fixtures :all
  include Devise::Test::ControllerHelpers

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end

class ActiveSupport::TestCase
  fixtures :all
  ActiveRecord::Migration.check_pending!

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end

  after do
    Sidekiq::Worker.clear_all
  end
end

class ActionMailer::TestCase
  fixtures :all

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end
