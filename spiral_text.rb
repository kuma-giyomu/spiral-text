#!/usr/bin/env ruby

class SpiralText

  PLACEHOLDER_CHAR = "\t"

  DIRECTION_RIGHT = 1
  DIRECTION_DOWN = 2
  DIRECTION_LEFT = 3
  DIRECTION_UP = 4

  def initialize
  end

  def encode(input)
    generate_grid(normalize(input))
  end

  def decode(input)
  end

  private

  def generate_grid(input)
    size = get_grid_size input
    grid = prepare_grid size

    populate_grid grid, input

    res = grid.inject "" do |grid_text, row|
      grid_text + row.join.gsub(PLACEHOLDER_CHAR, ' ') + "\n"
    end

    res
  end

  def populate_grid(grid, input)
    grid_position = {x: 0, y: 0, direction: DIRECTION_RIGHT}

    input.split(//).each do |cursor|
      place_character input[cursor], grid, grid_position
    end
  end

  def grid_char(grid, grid_position)
    grid[grid_position[:y]][grid_position[:x]]
  end

  def position_claimed?(grid, grid_position)
    grid_char(grid, grid_position) != PLACEHOLDER_CHAR
  end

  def apply_direction_offset(grid_position)
    # apply next position update
    grid_position[:x] +=  case grid_position[:direction]
                          when DIRECTION_LEFT
                            -1
                          when DIRECTION_RIGHT
                            1
                          else
                            0
                          end
    grid_position[:y] +=  case grid_position[:direction]
                          when DIRECTION_DOWN
                            1
                          when DIRECTION_UP
                            -1
                          else
                            0
                          end
  end

  def detect_direction_changes(grid, grid_position)
    size = grid.size
    # change of direction detection
    #
    # 1. hard boundaries detection
    grid_position[:direction] = DIRECTION_DOWN if grid_position[:direction] == DIRECTION_RIGHT && grid_position[:x] == size - 1
    grid_position[:direction] = DIRECTION_LEFT if grid_position[:direction] == DIRECTION_DOWN && grid_position[:y] == size - 1
    grid_position[:direction] = DIRECTION_UP if grid_position[:direction] == DIRECTION_LEFT && grid_position[:x] == 0
    grid_position[:direction] = DIRECTION_RIGHT if grid_position[:direction] == DIRECTION_UP && grid_position[:y] == 0

    candidate_position = grid_position.clone
    apply_direction_offset candidate_position

    # 2. existing text detection
    grid_position[:direction] = DIRECTION_DOWN if candidate_position[:direction] == DIRECTION_RIGHT && position_claimed?(grid, candidate_position)
    grid_position[:direction] = DIRECTION_LEFT if candidate_position[:direction] == DIRECTION_DOWN && position_claimed?(grid, candidate_position)
    grid_position[:direction] = DIRECTION_UP if candidate_position[:direction] == DIRECTION_LEFT && position_claimed?(grid, candidate_position)
    grid_position[:direction] = DIRECTION_RIGHT if candidate_position[:direction] == DIRECTION_UP && position_claimed?(grid, candidate_position)

    apply_direction_offset(grid_position)
  end

  def place_character(character, grid, grid_position)
    # set the character at the right position
    grid[grid_position[:y]][grid_position[:x]] = character

    detect_direction_changes(grid, grid_position)
  end

  def get_grid_size(input)
    Math.sqrt(input.size).ceil
  end

  def prepare_grid(size)
    grid = []

    (0...size).each do |i|
      grid[i] = [].fill PLACEHOLDER_CHAR, 0, size
    end

    grid
  end

  # normalize the input
  def normalize(input)
    # 1. strip white space characters, including the placeholder char
    input.gsub /\s+/, ' '
  end
end

puts SpiralText.new.encode ARGF.read
