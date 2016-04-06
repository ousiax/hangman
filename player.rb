#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'Hangman/hangman'
module Hangman

  def self.puts_message(message)
    puts ">>> #{message}"
  end

  LETTERS = ('A'..'Z').to_a
  PLAYER_ID = "xyz@qprt.com"
  REQUEST_URL = "http://www.domain-name.com/game/on"

  game = Game.new PLAYER_ID, REQUEST_URL

  res, err = game.start_game
  if err
    Abort("Abort! #{err}")
  end

  # Start game
  puts_message "#{res['message']}"

  total_word_count = 1
  until total_word_count > game.number_of_words_to_guess
    res, err = game.next_word
    if err
      Abort("Abort! #{err}")
    end

    # Guess a word #{total_word_count}/#{number_of_words_to_guess}"
    puts_message "Guess a word #{total_word_count}/#{game.number_of_words_to_guess}"

    word = res["data"]["word"]

    letters = LETTERS.clone
    number_of_guess  = 1
    until number_of_guess > game.number_of_guess_allowed_for_each_word
      letter = letters.sample
      letters.delete(letter)

      # Guess a letter
      puts_message "(#{number_of_guess.to_s.rjust(2)}) Guess '#{letter}' in '#{word}'"

      res, err = game.guess_word letter
      if err
        Abort("Abort! #{err}")
      end
      unless word.include? '*'
        break
      end
      word = res["data"]['word']
      # TODO: Optimize guess algorithm.
      # wrong_guess_count _of_current_word = res["data"]['wrongGuessCountOfCurrentWord']
      number_of_guess += 1
    end
    total_word_count += 1
  end

  # Get result
  res, err = game.get_result
  if err
    abort("Abort! #{err}")
  end
  data = res["data"]
  puts_message "---------------------------\n" \
    "totalWordCount: #{data['totalWordCount']}\n" \
    "correctWordCount: #{data['correctWordCount']}\n" \
    "totalWrongGuessCount: #{data['totalWrongGuessCount']}\n" \
    "score: #{data['score']}\n" \
    "---------------------------\n"

  # Submit results
  res, err = game.submit_result
  if err
    abort("Abort! #{err}")
  end
end

__END__
