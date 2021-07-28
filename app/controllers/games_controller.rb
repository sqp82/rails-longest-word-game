require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    # build the grid
    @grid = generate_grid(10).join
    @start_time = Time.now
  end

  def score
    # Retrieve all game data from form
    grid = params[:grid].split("")
    @word = params[:word]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    # Compute score
    @result = run_game(@word, grid, start_time, end_time)

  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end
  
  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end
  
  def compute_score(word, time_taken)
    time_taken > 60.0 ? 0 : word.size * (1.0 - time_taken / 60.0)
  end
  
  def run_game(word, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = { time: end_time - start_time }
  
    score_and_message = score_and_message(word, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
  
    result
  end
  
  def score_and_message(word, grid, time)
    if included?(word.upcase, grid)
      if english_word?(word)
        score = compute_score(word, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end
  
  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
  
end
