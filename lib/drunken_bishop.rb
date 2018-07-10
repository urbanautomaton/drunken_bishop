require 'digest/md5'

class DrunkenBishop
  HEIGHT = 9
  WIDTH = 17
  START_POSITION = [8, 4]
  OFFSETS = {
    0b00 => [-1, -1],
    0b01 => [1,  -1],
    0b10 => [-1,  1],
    0b11 => [1,   1]
  }.freeze

  CHARACTERS = ([' '] + %w( . o + = * B O X @ % & # / ^ S E )).freeze

  FIELD_TEMPLATE = (<<~EOS).gsub(/ +/, '%s')
    +-----------------+
    |                 |
    |                 |
    |                 |
    |                 |
    |                 |
    |                 |
    |                 |
    |                 |
    |                 |
    +-----------------+
  EOS

  def initialize(hash)
    @hash = hash
  end

  def moves
    Array(hash).pack('H*').bytes.flat_map do |byte|
      (0..3).map do |offset|
        (byte >> (2 * offset)) & 0b11
      end
    end
  end

  def to_s
    rows = counts.map do |row|
      row.map { |c| character_for(c) }.join
    end

    sprintf(FIELD_TEMPLATE, *rows)
  end

  def counts
    @counts ||= Array.new(HEIGHT * WIDTH, 0).tap do |counts|
      position = [8, 4]
      record_position(position, counts)

      moves.each do |move|
        offset = OFFSETS[move]
        position = apply_move(offset, position)
        record_position(position, counts)
      end

      set_position([8, 4], counts, 15)
      set_position(position, counts, 16)
    end.each_slice(WIDTH).to_a
  end

  protected

  def apply_move((ox, oy), (px, py))
    [
      (ox + px).clamp(0, WIDTH - 1),
      (oy + py).clamp(0, HEIGHT - 1)
    ]
  end

  def set_position((x, y), counts, value)
    counts[y * WIDTH + x] = value
  end

  def record_position((x,y), counts)
    counts[y * WIDTH + x] += 1
  end

  def character_for(count)
    CHARACTERS.fetch(count, CHARACTERS.last)
  end

  attr_reader :hash

end
