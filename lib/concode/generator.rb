require 'digest'

module Concode
  class Generator
    attr_reader :adjectives, :max_chars, :glue, :capitalize

    def initialize(adjectives: 1, max_chars: 0, glue: '-', capitalize: false)
      @adjectives = adjectives
      @glue = glue
      @capitalize = capitalize
      @max_chars = max_chars

      @max_chars = 3 if max_chars.between? 1, 3
      @max_chars = 0 if max_chars > 9
    end

    def generate(text)
      result = generate_particles text
      result.map!(&:capitalize) if capitalize
      result.join glue
    end

    def word_count
      @word_count ||= particles.map(&:size).reduce(:*)
    end

    private

    def particles
      @particles ||= particles!
    end

    def particles!
      result = [ Dictionary.nouns ]
      adjectives.times { result.push Dictionary.adjectives }

      if max_chars > 0
        result[0] = Dictionary.nouns[0...Dictionary.noun_lengths[max_chars]]
        adjectives.times { |i| result[i+1] = Dictionary.adjectives[0...Dictionary.adjective_lengths[max_chars]] }
      end

      result
    end

    def generate_particles(text)
      index = text_hash(text) % word_count

      result = []
      particles.each do |p|
        result.push p[index % p.size]
        index = (index / p.size).to_i
      end

      result.reverse
    end

    def text_hash(text)
      text = text.to_s
      Digest::MD5.hexdigest(text).to_i(16) * 36413321723440003717
    end
  end
end