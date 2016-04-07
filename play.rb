#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'Hangman/player'

module Hangman
  # player_id = "xyz@qprt.com"
  # request_url = "http://www.domain-name.com/game/on"
  File.open("player.info") do |f|
    PLAYER_ID, REQUEST_URL = eval(f.readline)
  end
  player = Player.new PLAYER_ID, REQUEST_URL
  player.play_game
  player.get_result
  player.submit_result
end

__END__
