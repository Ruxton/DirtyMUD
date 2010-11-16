require 'i18n'

requires = %w(room player server item mob)
requires.each do |r|
  require File.expand_path("../dirtymud/#{r}", __FILE__)
end
Dir.glob("config/i18n/*.yml").each do |locale|
  I18n.load_path << locale
end
