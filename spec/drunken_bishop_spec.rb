require 'spec_helper'
require 'drunken_bishop'

RSpec.describe DrunkenBishop do
  subject { described_class.new(hash) }

  describe '#moves' do
    context 'for a 128-bit hash' do
      let(:input) { 'thish ish good sherry' }
      let(:hash) { Digest::MD5.hexdigest(input) }

      it 'returns 64 moves' do
        expect(subject.moves.length).to eq 64
      end
    end

    context 'for a short hash' do
      let(:hash) { 'fc94' }

      it 'returns moves in the range 0-3 based on the bit pattern of the hash' do
        # Fingerprint       fc     :      94     : ...
        # Bits         11 11 11 00   10 01 01 00 : ...
        # Move no.     4  3  2  1    8  7  6  5
        expect(subject.moves).to eq([
          0b00,
          0b11,
          0b11,
          0b11,
          0b00,
          0b01,
          0b01,
          0b10
        ])
      end
    end
  end

  describe '#to_s' do
    context 'for a hash with four up-and-left moves' do
      let(:hash) { '00' }

      it 'prints the start, three periods and the end position' do
        expect(subject.to_s).to eq(<<~EOS)
          +-----------------+
          |    E            |
          |     .           |
          |      .          |
          |       .         |
          |        S        |
          |                 |
          |                 |
          |                 |
          |                 |
          +-----------------+
        EOS
      end
    end

    context 'for a hash with twelve up-and-left moves' do
      let(:hash) { '000000' }

      it 'traverses the top of the field' do
        expect(subject.to_s).to eq(<<~EOS)
          +-----------------+
          |E....            |
          |     .           |
          |      .          |
          |       .         |
          |        S        |
          |                 |
          |                 |
          |                 |
          |                 |
          +-----------------+
        EOS
      end
    end

    context 'for a hash with twelve down-and-right moves' do
      let(:hash) { 'FFFFFF' }

      it 'traverses the bottom of the field and gets stuck in the corner' do
        expect(subject.to_s).to eq(<<~EOS)
          +-----------------+
          |                 |
          |                 |
          |                 |
          |                 |
          |        S        |
          |         .       |
          |          .      |
          |           .     |
          |            ....E|
          +-----------------+
        EOS
      end
    end

    context 'for a complex hash' do
      let(:input) { 'thish ish good sherry' }
      let(:hash) { Digest::MD5.hexdigest(input) }

      it 'produces a full picture' do
        expect(subject.to_s).to eq(<<~EOS)
          +-----------------+
          |     ...**=B+    |
          |     ..+ o+o     |
          |    . + . o .    |
          |     o . . o     |
          |    .   S +      |
          |       . =       |
          |      E .        |
          |                 |
          |                 |
          +-----------------+
        EOS
      end
    end
  end
end
