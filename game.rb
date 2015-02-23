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
    puts "Welcome to Chess!"
    until game_over?
      update_players
      piece_moving
      take_turn
    end
    take_turn
    puts "Game over: #{@current_player} wins!"
  end

  def update_players
    puts
    puts "It's #{current_player}'s turn to move"
    puts
    puts grid.render
  end

  def get_from_pos(input)
    until input == 'f'
      input = STDIN.getch
      grid.cursor_position(input)
      puts grid.render
    end
    from_pos = grid.cursor.dup
  end

  def get_to_pos(input)
    until input == 't'
      input = STDIN.getch
      grid.cursor_position(input)
      puts grid.render
    end
    to_pos = grid.cursor.dup
  end

  def get_piece(from_pos)
    piece = grid[from_pos]
  end

  def piece_moving
    begin
      input = nil
      from_pos = get_from_pos(input)
      piece = get_piece(from_pos)
      puts "Testing cursor selection"
      print "Piece is "; p piece
      raise NotAPieceError.new("That's not a piece!") if piece.nil?
      raise NotYourPieceError.new("That's not your piece!") if piece.color != current_player
    rescue NotYourPieceError => e
      puts e.message
      retry
    rescue NotAPieceError => f
      puts f.message
      retry
    end

    begin
      input = nil
      puts "Valid moves are: #{piece.valid_moves}"
      puts "Where do you want to move it?"
      to_pos = get_to_pos(input)
      raise InvalidMoveError.new("Not a valid move! Please pick a valid move.") unless piece.valid_moves.include?(to_pos)
    rescue InvalidMoveError => g
      puts g.message
      retry
    end
    grid.move_piece!(from_pos, to_pos)
  end

  def take_turn
    turns = Hash["white", "black", "black", "white"]
    @current_player = turns[current_player]
  end
end
system("clear")
g = Game.new
g.play

system("clear")
