# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu

require_relative 'free_hangman_solver'

module Hangman
  class LettersGenerator
    LETTERS = ('A'..'Z').to_a
    OPT_LETTERS_CHART = {
      1 => ['A', 'I',],
      2 => ['A', 'O', 'E', 'I', 'U', 'M', 'B', 'H',],
      3 => ['A', 'E', 'O', 'I', 'U', 'Y', 'H', 'B', 'C', 'K'],
      4 => ['A', 'E', 'O', 'I', 'U', 'Y', 'S', 'B', 'F',],
      5 => ['S', 'E', 'A', 'O', 'I', 'U', 'Y', 'H',],
      6 => ['E', 'A', 'I', 'O', 'U', 'S', 'Y',],
      7 => ['E', 'I', 'A', 'O', 'U', 'S',],
      8 => ['E', 'I', 'A', 'O', 'U',],
      9 => ['E', 'I', 'A', 'O', 'U',],
      10 => ['E', 'I', 'O', 'A', 'U',],
      11 => ['E', 'I', 'O', 'A', 'D',],
      12 => ['E', 'I', 'O', 'A', 'F',],
      13 => ['I', 'E', 'O', 'A',],
      14 => ['I', 'E', 'O',],
      15 => ['I', 'E', 'A',],
      16 => ['I', 'E', 'H',],
      17 => ['I', 'E', 'R',],
      18 => ['I', 'E', 'A',],
      19 => ['I', 'E', 'A',],
      20 => ['I', 'E',]
    }

    def print_message(message)
      puts " -> #{message}"
    end

    def initialize(length)
      raise "'length' Required a Integer value." unless length.is_a? Integer
      rewind length
      @fiber = Fiber.new { |word|
        hangman_solver = FreeHangmanSolver.new
        loop do
          unless @last_word == word # Retrieves optimal letters.
            @last_word = word
            @opt_letters = hangman_solver.next word
            @opt_letters -= @not_letters
            @rest_letter = LETTERS.clone()  - @opt_letters - @not_letters
            print_message @opt_letters
          end
          letter = @opt_letters.shift
          # letter = @opt_letters.delete(@opt_letters.sample)
          letter ||=  @rest_letter.delete(@rest_letter.sample)
          @not_letters << letter
          word = Fiber.yield letter
        end
      }
    end

    def next(word)    # Return the next letter
      raise "'word' Required a String value." unless word.is_a? String
      @fiber.resume word.gsub('*', '.')
    end

    def rewind(length)  # Restart the sequence
      raise "'length' Required a Integer value." unless length.is_a? Integer
      if length >= 1 && length <= 20
        @opt_letters = OPT_LETTERS_CHART[length].clone
        @last_word = Array.new(length){ '.' }.join()
      else
        @opt_letters = []
        @last_word = nil  # Reset @last_word as nil to retrieve @opt_letters from FreeHangmanSolver.
      end
      @not_letters = []
      @rest_letter = LETTERS.clone()  - @opt_letters - @not_letters
      print_message @opt_letters if @opt_letters.size > 0
    end
  end
end
