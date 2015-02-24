require_relative 'pieces/pieces.rb'

class Board
  attr_accessor :chess_board, :cursor

  def initialize(setup = true)
    set_up_game(setup)
    @cursor = [0, 0]
  end

  def self.on_board?(pos)
    pos.all? { |coord| (0..7).cover? coord }
  end



  def move_piece!(from_pos, to_pos) # used to actually move piece
    piece = self[from_pos]
    p "#{piece.valid_moves} are the valid moves for #{piece}"
    self[to_pos] = piece
    self[from_pos] = nil
    piece.pos = to_pos
    piece.moved = true if piece.is_a?(Pawn)
  end

  def move(from_pos, to_pos) # only used by valid_moves
    piece = self[from_pos]
    self[to_pos] = piece
    self[from_pos] = nil
    piece.pos = to_pos
  end

  def all_moves(piece)
    piece.moves
  end

  def piece_at_position?(position)
    !self[position].nil?
  end

  def dup_board
    possible_board = Board.new(false)
    flattened = chess_board.flatten.compact
    flattened.each do |piece|
      raise "Look at me!" if piece.is_a?(Fixnum)
      possible_board[piece.pos] = piece.class.new(possible_board, piece.pos, piece.color)
    end
    possible_board
  end


  def [](pos)
    row, col = pos
    chess_board[row][col]
  end

  def []=(pos, piece)
    row, col = pos
    chess_board[row][col] = piece
  end

  def add_piece(pos, piece)
    self[pos] = piece
  end

  def cursor_position(input_letter)
    case input_letter
    when 'w'
      @cursor[0] -= 1 if @cursor[0] > 0
    when 's'
      @cursor[0] += 1 if @cursor[0] < 7
    when 'a'
      @cursor[1] -= 1 if @cursor[1] > 0
    when 'd'
      @cursor[1] += 1 if @cursor[1] < 7
    when 't'
      @cursor
    when 'f'
      @cursor
    when 'x'
      exit
    end
  end

  def colorize(square, i, j)
    square.nil? ? object_to_colorize = '  ' : object_to_colorize = square.inspect
    if [i, j] == @cursor
      object_to_colorize.colorize(:background => :yellow)
    elsif (i + j).odd?
      object_to_colorize.colorize(:background => :light_gray)
    else
      object_to_colorize.colorize(:background => :blue)
    end
  end

  def render(current_player)
    system("clear")
    num = 8
    "  Welcome to Chess" +
    "\n\n WASD To move cursor, \n F to select piece to move, \n T to place it" +
    "\n X to exit" +
    "\n\n  A B C D E F G H\n" + chess_board.map.with_index do |row, i|
      rend = row.map.with_index do |square, j|
        colorize(square, i, j)
      end
      rend = rend.join("")
      rend = [] << rend
      rend = rend.map { |elem| "#{num} #{elem}"}
      num -= 1
      rend
    end.join("\n") + "\n\nIts #{current_player}'s turn to move"
  end

  def in_check?(color)
    opponents = get_all_not_color(color)
    king = king_position(color)
    opponents.any? do |opp|
      moves = all_moves(opp)
      moves.include? king
    end
  end

  def check_mate?(color)
    teammates = get_all_color(color)
    teammates.all? { |teammate| teammate.valid_moves.empty? }
    # What about taking out pieces that are causing check?
  end

  def king_position(color)
    get_all_color(color).select{ |el| el.is_a? King }[0].pos
  end

  def get_all_color(color)
    flat_board = chess_board.flatten.compact
    flat_board.select {|el| el.color == color }
  end

  def get_all_not_color(color)
    flat_board = chess_board.flatten.compact
    flat_board.select { |el| el.color != color }
  end

  def set_up_game(setup = true)
    @chess_board = Array.new(8) { Array.new(8) { nil } }
    if setup
      ["white", "black"].each do |color|
        place_pawns(color)
        place_pieces(color)
      end
    end
  end

  def place_pawns(color)
    if color == "white"
      row = 1
    elsif color == "black"
      row = 6
    end
    8.times { |col| Pawn.new(self, [row, col], color)}

  end

  def place_pieces(color)
    pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    if color == "white"
      row = 0
    elsif color == "black"
      row = 7
    end
    pieces.each_with_index do |piece, col|
      piece.new(self, [row, col], color)
    end
  end


end
