# encoding: utf-8
# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

Reckoning::Application.config.session_store :cookie_store, key: '_reckoning_session', domain: ".#{Rails.application.secrets[:domain]}"

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# MortikFactura::Application.config.session_store :active_record_store
