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
      BGG::LoggedPlay.new(
        game_id: bga_name_to_bgg_id(play.name),
        scores: play.scores,
        duration_mins: play.duration_mins, time: play.time
      )
    end

    # @return [Integer] the BGG id of the game if known
    # @raise [UnknownGame] if game is unknown
    def bga_name_to_bgg_id(name)
      games = {
        notalone: 194879,
        coltexpress: 158899,
        sechsnimmt: 432,
        sevenwonders: 68448,
        sushigo: 133473,
        dudo: 45,
        taluva: 24508,
        coupcitystate: 131357,
        saboteur: 9220,
        cantstop: 41
      }

      raise UnknownGame, "#{name} game on BGA is unknown" unless games.key?(name.to_sym)

      games[name.to_sym]
    end
  end
end
