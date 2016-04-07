# -*- coding: utf-8 -*-

# The MIT License (MIT)
#
# Copyright (c) 2016 Roy Xu

require 'rest-client'
require 'json'

module Hangman
  class Game
    ERROR_HTTP_STATUS_CODES = [400, 401, 404, 422, 500]
    HEADERS = { content_type: "application/json", accept: "application/json" }

    def initialize(player_id, request_url)
      raise "'player_id' Required." unless player_id
      raise "'request_url' Required." unless request_url
      @player_id = player_id
      @request_url = request_url

      @session_id = nil
      @number_of_words_to_guess = 0
      @number_of_guess_allowed_for_each_word = 0
    end

    def number_of_words_to_guess
      @number_of_words_to_guess
    end

    def number_of_guess_allowed_for_each_word
      @number_of_guess_allowed_for_each_word
    end

    # Returns a tuple [response, message].
    #
    # The 1st element `response` represent a response message with a `hash` object.
    #
    # The 2nd element `message` represents a error message,
    # and `nil` value indicates it exited normally, otherwise there was an error.
    def post(payload)
      begin
        raw_response = RestClient.post @request_url, payload.to_json, HEADERS
        if raw_response.code > 200
          [nil, "Unhandled Exception!"]
        else
          res = JSON.parse raw_response.body
          [res, nil]
        end
      rescue RestClient::Exception => ex
        if ERROR_HTTP_STATUS_CODES.include? ex.http_code
          res = JSON.parse ex.http_body
          message = res['message']
        else
          message = ex.message
        end
        [nil, message]
      end
    end
    private :post

    # 1. Start Game
    def start_game
      payload = {
        playerId: @player_id,
        action: "startGame",
      }
      res, err =  post payload
      unless err
        @session_id = res["sessionId"]
        @number_of_words_to_guess = res["data"]["numberOfWordsToGuess"].to_i
        @number_of_guess_allowed_for_each_word = res["data"]["numberOfGuessAllowedForEachWord"].to_i
      end
      [res, err]
    end

    # 2. Give Me A Word
    def next_word
      payload = {
        sessionId: @session_id,
        action: "nextWord",
      }
      post payload
    end

    # 3. Make A Guess
    def guess_word(letter)
      payload = {
        sessionId: @session_id,
        action: "guessWord",
        guess: letter,
      }
      post payload
    end

    # 4. Get Your Result
    def get_result
      payload = {
        sessionId: @session_id,
        action: "getResult",
      }
      post payload
    end

    # 5. Submit Your Result
    def submit_result
      payload = {
        sessionId: @session_id,
        action: "submitResult",
      }
      post payload
    end
  end
end
