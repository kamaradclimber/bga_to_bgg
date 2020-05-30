# frozen_string_literal: true

require 'bga_to_bgg'

RSpec.describe BgaToBgg do
  # integration test
  describe 'equality testing on BGG::LoggedPlay' do
    subject do
      BgaToBgg::BGG::LoggedPlay.from_h(hash)
    end

    let(:hash) do
      JSON.parse('{"id":"23428046", "date":"2017-05-06", "quantity":"2", "length":"0", "incomplete":"0", "nowinstats":"0", "location":"Paris", "item":[{"name":"Not Alone", "objecttype":"thing", "objectid":"194879", "subtypes":[{"subtype":[{"value":"boardgame"}]}]}], "players":[{"player":[{"username":"", "userid":"0", "name":"Noemi", "startposition":"1", "color":"", "score":"0", "new":"1", "rating":"0", "win":"1"}, {"username":"", "userid":"0", "name":"Anthony", "startposition":"2", "color":"", "score":"-1", "new":"0", "rating":"-1", "win":"0"}, {"username":"", "userid":"0", "name":"Nathalie", "startposition":"3", "color":"", "score":"-1", "new":"0", "rating":"0", "win":"0"}, {"username":"kamaradclimber", "userid":"1003032", "name":"kamaradclimber", "startposition":"4", "color":"", "score":"-1", "new":"1", "rating":"0", "win":"0"}]}]}') # rubocop:disable Layout/LineLength
    end

    it 'is equal to a manually defined LoggedPlay' do
      expected_play = BgaToBgg::BGG::LoggedPlay.new(
        game_id: 194879,
        scores: {
          '/Noemi/0': '0',
          '/Anthony/0': '-1',
          '/Nathalie/0': '-1',
          'kamaradclimber/kamaradclimber/1003032': '-1'
        },
        duration_mins: 0,
        time: Time.new(2017, 5, 6)
      )
      expect(subject.to_h).to eq(expected_play.to_h)
    end
  end
end
