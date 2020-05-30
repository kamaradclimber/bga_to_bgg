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
      if KNOWN_BGG_USERS.key?(bga_player.to_sym)
        bgg_player = KNOWN_BGG_USERS[bga_player.to_sym]
        "#{bgg_player[:username]}/#{bgg_player[:name] || bga_player}/#{bgg_player[:id]}"
      else
        "/#{bga_player}/0"
      end
    end

    # keys are BGA identifier
    # values are { username: <bgg username>, id: <bgg user id> }
    KNOWN_BGG_USERS = {
      kamaradclimber: { username: 'kamaradclimber', id: 1003032 },
      tchouktchouka: { username: '', id: 0, name: 'Noemi' },
      FloSeux: { username: '', id: 0, name: 'Florentin' },
      sevsevsev: { username: '', id: 0, name: 'Séverin' },
      Léovirus: { username: '', id: 0, name: 'Éléonore' },
      griseya: { username: '', id: 0, name: 'Nathalie' },
      ngrisey: { username: '', id: 0, name: 'Anthony' }, # yes pseudo are reversed
      LeBuveur: { username: '', id: 0, name: 'Nicolas Grégis' },
      kOral: { username: '', id: 0, name: 'Chahine' },
      Wahoo2011: { username: '', id: 0, name: 'Chris' },
    }.freeze

    KNOWN_GAMES = {
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
    }.freeze

    # @return [Integer] the BGG id of the game if known
    # @raise [UnknownGame] if game is unknown
    def bga_name_to_bgg_id(name)
      raise UnknownGame, "#{name} game on BGA is unknown" unless KNOWN_GAMES.key?(name.to_sym)

      # TODO(g.seux): of course we should fetch that info dynamically, but how?
      KNOWN_GAMES[name.to_sym]
    end
  end
end
