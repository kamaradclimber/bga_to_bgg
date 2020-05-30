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

      def plays(game_id:, page: 1, previous_plays: [])
        require 'xmlsimple'

        response_content = http_client.get_content(File.join(BGG_URL, 'xmlapi2/plays'), { username: @username, type: 'thing', id: game_id, page: page })

        xml = XmlSimple.xml_in(response_content)
        current_plays = xml['play'].map { |p| LoggedPlay.from_h(p) }
        if xml['play'].size == 100
          plays(game_id: game_id, page: page + 1, previous_plays: previous_plays + current_plays)
        else
          previous_plays + current_plays
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
        @duration_mins = duration_mins.to_i
        @time = time
      end

      # Build a [LoggedPlay] using a logged play returned by /xmlapi2/plays api (see https://boardgamegeek.com/wiki/page/BGG_XML_API2)
      # @param [Hash] a hash describing the logged play. It must follow format of boardgamegeek /xmlapi2/plays api
      # @return [LoggedPlay]
      def self.from_h(hash)
        # for a weird reason the format for players is an array of size 1
        raise 'players value should be an array of size 1' unless hash['players'].size == 1

        scores = hash['players'].first['player'].map do |player|
          serialized_id = "#{player['username']}/#{player['name']}/#{player['userid']}"
          [serialized_id, player['score'].to_i]
        end.to_h

        LoggedPlay.new(
          game_id: hash['item'].first['objectid'],
          duration_mins: hash['length'].to_i,
          time: Time.parse(hash['date']),
          scores: scores,
        )
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
        @scores.each do |serialized_id, score|
          player_username, player_name, player_id = serialized_id.split('/', 3)
          hash[:players] << {
            username: player_username,
            userid: player_id.to_i,
            score: score,
            repeat: 'true',
            name: player_name,
            win: score.to_i == @scores.values.map(&:to_i).max,
            selected: 'false'
          }
        end
        hash
      end
    end
  end
end
