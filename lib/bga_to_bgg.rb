# frozen_string_literal: true

require 'bga_to_bgg/version'
require 'bga_to_bgg/bga'
require 'bga_to_bgg/bgg'

module BgaToBgg
  # A converter from one class to another, see #convert method
  class BgaGameToBggGame
    class UnknownGame < StandardError; end

    # @param [BGA::GamePlay]
    # @return [BGG::LoggedPlay]
    def to_bgg(play)
      scores = play.scores.map do |bga_player, score|
        serialized_id = to_bgg_player_id(bga_player)
        [serialized_id, score.to_i]
      end.to_h

      BGG::LoggedPlay.new(
        game_id: bga_name_to_bgg_id(play.name),
        scores: scores,
        duration_mins: play.duration_mins, time: play.time
      )
    end

    private

    # @param bga_player [String,Symbol] the BGA nickname
    # @return [String] a BGG serialized id
    def to_bgg_player_id(bga_player)
      # bgg normalize player name by stripping trailing whitespace
      bga_player = bga_player.strip
      if known_bgg_users.key?(bga_player.to_s)
        bgg_player = known_bgg_users[bga_player.to_s]
        "#{bgg_player['username']}/#{bgg_player['name'] || bga_player}/#{bgg_player['id']}"
      else
        "/#{bga_player}/0"
      end
    end

    def known_bgg_users
      # keys are BGA identifier
      # values are { username: <bgg username>, id: <bgg user id> }
      @known_bgg_users ||= begin
                   users_file = ENV['USERS_FILE']
                   JSON.parse(File.read(users_file))
                 end
    end

    def known_games
      @known_games ||= begin
                         game_file = ENV['GAME_FILE'] || 'games.json'
                         JSON.parse(File.read(game_file))
                       end
    end

    # @return [Integer] the BGG id of the game if known
    # @raise [UnknownGame] if game is unknown
    def bga_name_to_bgg_id(name)
      raise UnknownGame, "#{name} game on BGA is unknown" unless known_games.key?(name)

      # TODO(g.seux): of course we should fetch that info dynamically, but how?
      known_games[name]
    end
  end
end
