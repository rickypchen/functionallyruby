require 'csv'

class FifaLeaderBoardFunc
  def self.display(csv_file)
    new(csv_file).display
  end

  def display
    import_csv
      .then(&process_csv_data_to_hash)
      .then(&get_completed_games)
      .then(&tally_total_scores_by_country)
      .then(&rank_country_by_scores)
      .then(&format_stats_to_hash)
  end

  def initialize(csv_file)
    @csv_file = csv_file
  end
  private_class_method :new

  private

  def import_csv
    CSV.read(@csv_file, {
      headers: true,
      header_converters: lambda { |h| h.downcase.gsub(' ', '_') }
    })
  end

  def process_csv_data_to_hash
    -> (csv_data) { csv_data.map { |row| row.to_h } }
  end

  def get_completed_games
    -> (hash_array) { hash_array.select { |row| !row['result'].nil? } }
  end

  def tally_total_scores_by_country
    -> (completed_games) { completed_games.reduce({}) { |hash, game| total_goals_tally(hash, game) }}
  end

  def rank_country_by_scores
    -> (total_goals_hash) { total_goals_hash.sort_by { |country, goals| -goals }}
  end

  def format_stats_to_hash
    -> (teams_ranked_by_total_goals) { teams_ranked_by_total_goals.to_h }
  end

  def get_score(side, result_string)
    side == 'home_team' ? result_string.split(" - ")[0].to_i : result_string.split(" - ")[1].to_i
  end

  def tally_scores(team_name, score, goals_hash)
    if goals_hash[team_name].nil?
      goals_hash[team_name] = score
    else
      goals_hash[team_name] += score
    end
  end

  def total_goals_tally(hash, game)
    tally_scores(game['home_team'], get_score('home_team', game['result']), hash)
    tally_scores(game['away_team'], get_score('away_team', game['result']), hash)
    hash
  end
end

puts FifaLeaderBoardFunc.display('fifa-wc-2019.csv')
