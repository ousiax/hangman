#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'Hangman/player'
require 'io/console'

module Hangman
  # player_id = "xyz@qprt.com"
  # request_url = "http://www.domain-name.com/game/on"
  File.open("player.info") do |f|
    PLAYER_ID, REQUEST_URL = eval(f.readline)
  end
  player = Player.new PLAYER_ID, REQUEST_URL
  player.play_game
  player.get_result

  puts "Submit result?Y/N"
  ch = STDIN.getch.upcase
  if ch == 'Y'
    player.submit_result
  else
    puts "Abandon this result!"
  end
end

__END__
