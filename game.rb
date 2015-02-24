require_relative 'board.rb'
require_relative 'not_your_piece.rb'
require 'colorize'
require 'io/console'
require 'byebug'


class Game

  attr_reader :grid
  attr_accessor :current_player

  def initialize
    @cursor = [0,0]
    @grid = Board.new
    @current_player = "white"
  end

  def game_over?
    grid.check_mate?('white') || grid.check_mate?('black')
  end

  def play
    until game_over?
      update_players
      piece_moving
      take_turn
    end
    take_turn
    puts "Game over: #{@current_player} wins!"
  end

  def update_players
    puts grid.render(@current_player)
  end

  def fancy_render(piece)
    grid.render(@current_player) +
    "\nPiece is #{piece.inspect}" +
    "\nValid moves are: #{piece.print_valid_moves}" +
    "\nWhere do you want to move it?"
  end


  def get_from_pos(input)
    begin
      until input == 'f'
        input = STDIN.getch
        grid.cursor_position(input)
        puts grid.render(@current_player)
      end
      from_pos = grid.cursor.dup
      piece = get_piece(from_pos)
      raise NotAPieceError.new("That's not a piece!") if piece.nil?
      raise NotYourPieceError.new("That's not your piece!") if piece.color != current_player
      raise NoMovesAvailableError.new("No moves available for that piece!") if piece.valid_moves.empty?
    rescue NotYourPieceError => e
      puts e.message
      input = ""
      retry
    rescue NotAPieceError => f
      puts f.message
      input = ""
      retry
    rescue NoMovesAvailableError => h
      puts h.message
      input = ""
      retry
    end
    puts fancy_render(piece)
    from_pos
  end

  def get_to_pos(input, piece)
    until input == 't'
      input = STDIN.getch
      grid.cursor_position(input)
      puts fancy_render(piece)
    end
    to_pos = grid.cursor.dup
  end

  def get_piece(from_pos)
    piece = grid[from_pos]
  end
  

  def get_piece_to_move
    begin
      input = nil
      from_pos = get_from_pos(input)
      piece = get_piece(from_pos)
      print
      raise NotAPieceError.new("That's not a piece!") if piece.nil?
      raise NotYourPieceError.new("That's not your piece!") if piece.color != current_player
      raise NoMovesAvailableError.new("No moves available for that piece!") if piece.valid_moves.empty?
    rescue NotYourPieceError => e
      puts e.message
      retry
    rescue NotAPieceError => f
      puts f.message
      retry
    rescue NoMovesAvailableError => h
      puts h.message
      retry
    end
    from_pos
  end

  def get_place_to_move_piece(piece)
    begin
      input = nil
      to_pos = get_to_pos(input, piece)
      unless piece.valid_moves.include?(to_pos)
        raise InvalidMoveError.new("Not a valid move! Please pick a valid move.")
      end
    rescue InvalidMoveError => g
      puts g.message
      retry
    end
    to_pos
  end

  def piece_moving
    from_pos = get_piece_to_move
    piece = get_piece(from_pos)
    to_pos = get_place_to_move_piece(piece)
    grid.move_piece!(from_pos, to_pos)
  end

  def take_turn
    turns = Hash["white", "black", "black", "white"]
    @current_player = turns[current_player]
    p "it is #{@current_player}'s turn!'"
  end
end

system("clear")
g = Game.new
g.play
system("clear")
