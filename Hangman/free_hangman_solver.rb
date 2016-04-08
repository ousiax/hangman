# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu

require 'net/http'

module Hangman
  class FreeHangmanSolver
    LETTERS_PATTERN = /<p>What Letter Should You Guess \(best first\):\n<br><b>(?<letters>[\w\s]*)/m#<\/b><\/p>/im
    REQUEST_URI = URI("http://hangman.doncolton.com/")

    def initialize
      @fiber = Fiber.new { |word|
        Net::HTTP.start(REQUEST_URI.host, REQUEST_URI.port) do |http|
          letters = []
          last_word = nil
          loop do
            unless last_word == word
              req = Net::HTTP::Post.new(REQUEST_URI)
              req["Host"] = "hangman.doncolton.com"
              req["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:45.0) Gecko/20100101 Firefox/45.0"
              req["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
              req["Accept-Language"] = "en-US,en;q=0.5"
              # req["Accept-Encoding"] = "gzip, deflate"
              req["Referer"] = "http://hangman.doncolton.com/"
              # req["Connection"] = "keep-alive"
              req.set_form_data(pat: word, not: "", submit: "hangman")
              begin
                res = http.request req
                case res
                when Net::HTTPOK
                  letters_match = LETTERS_PATTERN.match(res.body)
                  letters = letters_match[1].split(' ') if letters_match
                else
                  letters = []
                end
              rescue => ex
                puts " > FreeHangmanSolver##{ex.message}"
                letters = []
              end
            end
            word = Fiber.yield letters
          end
        end
      }
    end

    def next(word)
      raise "'word' Required a String value." unless word.is_a? String
      @fiber.resume word
    end
  end
end
