require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    @letters = []
    10.times { @letters.push(('A'..'Z').to_a.sample) }
    @start_time = Time.now
  end

  def api_input(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    dico_serialized = URI.open(url).read
    JSON.parse(dico_serialized)
  end

  def verify_word_is_in_grid?(word, grid)
    word.chars.all? do |lettre|
      indice = grid.index(lettre.upcase)
      if indice
        grid.delete_at(indice)
        true
      else
        false
      end
    end
  end

  def score
    start_time = params[:start_time].to_time
    end_time = Time.now
    attempt = params[:word]
    letters = params[:letters].split(' ')
    response_dico = api_input(attempt)
    scor = 0
    is_verify_ingrid = verify_word_is_in_grid?(attempt, letters)
    message = "#{attempt} is not an english word" unless response_dico['found']
    message = "#{attempt} is not in the grid" unless is_verify_ingrid
    if response_dico['found'] && is_verify_ingrid
      scor = (10 * response_dico['length'].to_i) + (100 - (end_time - start_time))
      message = "Congratulations #{attempt} is a valid english word"
    end
    @score_response = { attempt: attempt, score: scor, message: message, time: end_time - start_time }
  end
end
