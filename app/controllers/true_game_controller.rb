class TrueGameController < ApplicationController
  # GET /true_game/:game_id/:player_id/moves
  def get_moves
    render :text => ""
  end

  # GET /true_game/:game_id/:player_id/moves
  def post_moves
    render :text => request.body.size
  end
  
  # GET /true_game/:game_id/:player_id/moves
  def get_targets
    render :text => ""
  end

  # GET /true_game/:game_id/:player_id/moves
  def post_targets
    render :text => ""
  end
  
  # GET /true_game/:game_id/:player_id/moves
  def get_clean
    render :text => ""
  end

  # GET /true_game/:game_id/:player_id/moves
  def post_clean
    render :text => ""
  end
  
end
