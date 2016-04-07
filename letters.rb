# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu
module Hangman
  class LetterGenerator
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

    def initialize(length)
      @length = length
      @letters = LETTERS.clone
      @opt_letters = OPT_LETTERS_CHART[length] if length >= 1 && length <= 20
      @fiber = Fiber.new {
        opt_letters ||= []
        loop do
          letter = @opt_letters.shift
          letter ||= @letters.delete(@letters.sample)
          Fiber.yield letter
        end
      }
    end

    # TODO: optimize next letter with the current `word`.
    def next(word)    # Return the next letter
      @fiber.resume word
    end

    def rewind(length=nil)  # Restart the sequence
      @length = length || @length
      @letters = LETTERS.clone
      @opt_letters = OPT_LETTERS_CHART[length] if length >= 1 && length <= 20
    end

  end
end
