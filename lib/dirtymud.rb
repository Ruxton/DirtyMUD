requires = %w(responder entity room player server item npc)
requires.each do |r|
  require File.expand_path("../dirtymud/#{r}", __FILE__)
end
