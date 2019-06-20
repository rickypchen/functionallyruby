require 'csv'

class FifaLeaderBoard
  def initialize(csv_file)
    @csv_file = csv_file
    @csv_data = nil
  end

  def load
    @csv_data = CSV.read(@csv_file, {
      headers: true,
      header_converters: lambda { |h| h.downcase.gsub(' ', '_') }
    })
  end

  def display
    if !@csv_data.nil?
      array_of_hash = @csv_data.map { |row| row.to_h }
      completed_games = array_of_hash.select { |row| !row['result'].nil? }
      top_goals_hash = {}
      completed_games.each do |game|
        if top_goals_hash[game['home_team']].nil?
          top_goals_hash[game['home_team']] = game['result'].split(" - ")[0].to_i
        else
          top_goals_hash[game['home_team']] += game['result'].split(" - ")[0].to_i
        end
        if top_goals_hash[game['away_team']].nil?
          top_goals_hash[game['away_team']] = game['result'].split(" - ")[1].to_i
        else
          top_goals_hash[game['away_team']] += game['result'].split(" - ")[1].to_i
        end
      end
      teams_ranked_by_total_goals = top_goals_hash.sort_by { |country, goals| -goals }
      teams_ranked_by_total_goals.to_h
    else
      raise 'Need to first read csv file'
    end
  end
end

leader_board = FifaLeaderBoard.new('fifa-wc-2019.csv')
leader_board.load
puts leader_board.display
