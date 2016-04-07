# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu
require_relative 'hangman'
require_relative 'letters'

module Hangman
  class Player
    def initialize(player_id, request_url)
      raise "Require player_id!" unless player_id
      raise "Require request_url!" unless request_url
      @game = Game.new player_id, request_url
    end

    def puts_message(message)
      puts ">>> #{message}"
    end
    private :puts_message

    def start_game
      res, err = @game.start_game
      abort("Abort! #{err}") if err

      puts_message "#{res['message']}"
    end
    private :start_game

    def guess_words
      letters_generator = LetterGenerator.new 0
      total_word_count = 1
      until total_word_count > @game.number_of_words_to_guess
        res, err = @game.next_word
        abort("Abort! #{err}") if err

        puts_message "Guess a word #{total_word_count}/#{@game.number_of_words_to_guess}"

        word = res["data"]["word"]

        # rewind letters generator
        letters_generator.rewind word.size

        number_of_guess  = 1
        until number_of_guess > @game.number_of_guess_allowed_for_each_word
          # Guess a letter in word
          letter = letters_generator.next word
          raise "No more letters to guess." unless letter
          puts_message "(#{number_of_guess.to_s.rjust(2)}) Guess '#{letter}' in '#{word}', length: #{word.size}"

          res, err = @game.guess_word letter
          abort("Abort! #{err}") if err

          break unless word.include? '*'

          word = res["data"]['word']
          # TODO: Optimize guess algorithm.
          # wrong_guess_count _of_current_word = res["data"]['wrongGuessCountOfCurrentWord']
          number_of_guess += 1
        end
        total_word_count += 1
      end
    end
    private :guess_words

    def play_game
      start_game
      guess_words
    end

    # Get result
    def get_result
      res, err = @game.get_result
      abort("Abort! #{err}") if err

      data = res["data"]
      puts_message "---------------------------\n" \
        "totalWordCount: #{data['totalWordCount']}\n" \
        "correctWordCount: #{data['correctWordCount']}\n" \
        "totalWrongGuessCount: #{data['totalWrongGuessCount']}\n" \
        "score: #{data['score']}\n" \
        "---------------------------\n"
    end

    # Submit results
    def submit_result
      res, err = @game.submit_result
      abort("Abort! #{err}") if err
    end
  end
end
