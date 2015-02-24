class Piece
  attr_reader :color, :chess_board
  attr_accessor :pos

  DIAGONAL_MOVES = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
  CARDINAL_MOVES = [[-1, 0], [1, 0], [0, -1], [0, 1]]

  def diagonal
    DIAGONAL_MOVES
  end

  def cardinal
    CARDINAL_MOVES
  end

  def initialize(chess_board, pos, color)
    @chess_board = chess_board #board is an instance of the Board class
    @pos = pos # Initialized position to hard coded value like the beginning of chess
    @color = color

    chess_board.add_piece(pos, self)
  end

  def valid_moves
    true_valid_moves = []
    current_position = self.pos
    moves.each do |possible_move|
      possible_board = self.chess_board.dup_board
      possible_board.move(current_position, possible_move)
      true_valid_moves << possible_move unless possible_board.in_check?(self.color)
    end

    true_valid_moves
  end

  def print_valid_moves
    nums = (0..7).to_a
    nums_rev = (0..7).to_a.reverse.map{|el| el + 1}
    lets =  ("A".."H").to_a
    lets_hash = nums.zip(lets).to_h
    nums_hash = nums.zip(nums_rev).to_h
    new_form_valid_moves = valid_moves.map do |move|
      [lets_hash[move[1]], nums_hash[move[0]]]
    end
    new_form_valid_moves
  end
end
