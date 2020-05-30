require 'bga_to_bgg/version'
require 'httpclient'

module BgaToBgg
  module BGA
    class Client
      def initialize(username:, password:, player_id:)
        @username = username
        @password = password
        @player_id = player_id
      end

      # @returns [Array<BGA::GamePlay>] a list of game plays
      def history
        _history.map do |res|
          GamePlay.new()
        end
      end

      private

      def _history
        uri = File.join(BGA_URL, 'gamestats/gamestats/getGames.html')
        query = {
          player: @player_id,
          opponent_id: 0,
          finished: 0,
          updateStats: 1,
          'dojo.preventCache': Time.now.to_i # cache buster
        }

        headers = { 'User-Agent': 'BGA to BGG' }
        response = http_client.get(uri, query, headers)
        puts response.status
        JSON.parse(response.content)
      end

      BGA_URL = 'https://boardgamearena.com'.freeze

      def http_client
        @http_client ||= HTTPClient.new.tap do |c|
          c.set_auth(BGA_URL, @username, @password)
        end
      end
    end

    class GamePlay
      # @param :name [String] name of the game played
      # @param :scores [Hash] for each player key, their score as value
      # @param :time [Integer] time of the play in minutes
      def initialize(name:, scores:, time:)
      end
    end
  end
end
