require 'json'
require 'httpclient'

module BgaToBgg
  module BGG
    # A small client for boardgamegeek website
    class Client
      def initialize(username:, password:)
        @username = username
        @password = password
      end

      # @param [BGG::LoggedPlay] a game play to log
      # @return [String] html returned by boardgamegeek
      def log_play(play)
        uri = File.join(BGG_URL, 'geekplay.php')

        response = http_client.post(uri, play.to_json, DEFAULT_HEADERS)
        raise "Incorrect status #{response.status}" unless (200..299).include?(response.status.to_i)

        # content is some html output. We don't really need it
        response.content
      end

      BGG_URL = 'https://boardgamegeek.com'.freeze

      DEFAULT_HEADERS = {
        'User-Agent': 'BGA to BGG. Contact grego_bgatobgg@familleseux.net if needed',
        'Content-Type': 'application/json'
      }.freeze

      def http_client
        @http_client ||= HTTPClient.new.tap do |c|
          login_payload = { credentials: { username: @username, password: @password } }
          response = c.post(File.join(BGG_URL, 'login/api/v1'), login_payload.to_json, DEFAULT_HEADERS)
          raise "Incorrect status #{response.status}" unless (200..299).include?(response.status.to_i)
        end
      end
    end

    # A small wrapper around one single play
    class LoggedPlay
      # @param :name [String] name of the game played
      # @param :scores [Hash] for each player key, their score as value
      # @param :duration_mins [Integer] duration of the play in minutes
      # @param :time [Time] time of the play
      def initialize(game_id:, scores:, duration_mins:, time:)
        @game_id = game_id
        @scores = scores
        @duration_mins = duration_mins
        @time = time
      end

      # @return [String] the json format of the logged play
      def to_json
        to_h.to_json
      end

      # @return [Hash] the hash format of the logged play
      def to_h
        hash = {
          playdate: @time.strftime('%F'),
          comments: "logged by BGA-To-BGG on #{Time.now}",
          length: @duration_mins,
          minutes: @duration_mins,
          hours: 0,
          twitter: 'false',
          location: 'BoardGameArena',
          objectid: @game_id,
          quantity: '1',
          action: 'save',
          dateinput: Time.now.strftime('%F'),
          objecttype: 'thing',
          ajax: 1,
          players: []
        }
        @scores.each do |player, score|
          hash[:players] << {
            username: '',
            userid: 0,
            score: score,
            repeat: 'true',
            name: player,
            win: score.to_i == @scores.values.map(&:to_i).max,
            selected: 'false'
          }
        end
        hash
      end
    end
  end
end
