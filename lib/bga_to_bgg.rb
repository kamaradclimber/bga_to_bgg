# frozen_string_literal: true

require 'bga_to_bgg/version'
require 'httpclient'
require 'json'

module BgaToBgg
  module BGA
    # A small client for boardgamearena website
    class Client
      def initialize(username:, password:, player_id:)
        @username = username
        @password = password
        @player_id = player_id
      end

      # @returns [Array<BGA::GamePlay>] a list of game plays
      def history
        # TODO(g.seux): there is certainly a more ruby way of doing this
        _history.map do |res|
          next if res['normalend'] != '1'

          play_duration = (res['end'].to_i - res['start'].to_i) / 60

          scores = res['player_names'].split(',').zip(res['scores'].split(',')).to_h
          GamePlay.new(name: res['game_name'], duration_mins: play_duration, scores: scores, time: Time.at(res['start'].to_i))
        end.compact
      end

      private

      def _history(page: 1, previous_pages: [])
        uri = File.join(BGA_URL, 'gamestats/gamestats/getGames.html')
        query = {
          player: @player_id,
          opponent_id: 0,
          finished: 0,
          updateStats: 1,
          page: page,
          'dojo.preventCache': Time.now.to_i # cache buster
        }

        headers = { 'User-Agent': 'BGA to BGG. Contact grego_bgatobgg@familleseux.net if needed' }
        response = http_client.get(uri, query, headers)
        raise "Incorrect status #{response.status}" unless response.status.to_i == 200

        tables = JSON.parse(response.content)['data']['tables']
        return previous_pages unless tables.any?

        _history(page: page + 1, previous_pages: previous_pages + tables)
      end

      BGA_URL = 'https://en.boardgamearena.com'

      def http_client
        @http_client ||= HTTPClient.new.tap do |c|
          c.set_auth(BGA_URL, @username, @password)
        end
      end
    end

    # A small wrapper around one single play
    class GamePlay
      # @param :name [String] name of the game played
      # @param :scores [Hash] for each player key, their score as value
      # @param :duration_mins [Integer] duration of the play in minutes
      # @param :time [Time] time of the play
      def initialize(name:, scores:, duration_mins:, time:)
        @name = name
        @scores = scores
        @duration_mins = duration_mins
        @time = time
      end
    end
  end
end
