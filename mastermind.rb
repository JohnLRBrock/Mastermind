# John Brock
# 2016/10/1
# The Odin Project
# Mastermind


# supplies structure for the game
class Mastermind
  attr_writer :won
  def initialize
    @turn = 1
    @won = false
    @lost = false
    maker_or_breaker = welcome_message
    if maker_or_breaker
      computer_guesser
    else
      human_guesser
    end
  end

  # returns true if they want to be the code maker
  def welcome_message
    puts "----------------------\n"
    puts '    WELCOME HUMAN'
    puts "----------------------\n"
    puts 'Do you want to the be the code maker or code breaker? (m/b)'

    get_decision("m","b")
  end

  # TODO: nothing calls this
  def victory
    @won = true
    "That's right! You guessed all four! You won :D!\n"
  end

  #TODO: nothing calls this
  def computer_victory
    @won = true
    "The computer guessed correct! The Computer wins!\n"
  end

  def defeat
    @lost = true
    "That was your last turn! You lost D: The password was #{@passcode}.\n"
  end

  def computer_defeat
    @lost = true
    "That was the computer's last turn! The computer loses!\n"
  end

  def human_guesser
    passcode = Passcode.new
    passcode.create_passcode
    turn(passcode) until @lost || @won
  end

  def turn(passcode)
    puts "Turn #{@turn}"
    puts 'Guess the passcode.'
    guess = Passcode.new
    guess.get_code
    p guess
    check_result = passcode.check_passcode(guess)
    puts check_result.result
    puts victory if check_result.victory? 
    @turn += 1
    puts defeat if @turn == 13
  end

  def computer_guesser
    puts 'Type your secret passcode.'
    passcode = Passcode.new
    passcode.get_code
    passcode = computer_turn(passcode) until @lost || @won
  end

  def computer_turn(passcode)
    puts "Turn #{@turn}"
    guess = Passcode.new
    guess.computer_guess(passcode)
    p guess
    check_result = passcode.check_passcode(guess)
    puts check_result.result
    puts computer_victory if check_result.victory?
    @turn += 1
    puts computer_defeat if @turn == 13
    passcode
  end
end

class Passcode

  attr_accessor :passcode

  def initialize
    @passcode = []
    @size = 4
  end

  def [](ind)
    @passcode[ind]
  end

  def []=(ind, value)
    @passcode[ind] = value
  end

  def create_passcode
    4.times { |i| @passcode[i] = Digit.new(rand(1..6).to_s) }
  end
  
  def illegal_characters?(guess)
    no_illegal_characters = true
    guess.each{ |digit| no_illegal_characters = false unless ('1'..'6').cover?(digit) }
    no_illegal_characters
  end

  def get_code
    loop do
      code = gets.chomp.chars
      if code.size == @size && illegal_characters?(code)
        4.times { |i| @passcode.push(Digit.new(code.unshift))}
        break
      elsif code.size != @size
        puts "Your guess must have #{@size} characters."
      else
        puts 'Please only use the numbers 1-6 in your answers.'
      end
    end
  end

  #TODO: undefined method 'number' on nilclass (Probably guess)
  def position_check(guess)
    4.times do |i|
      if guess[i].number == @passcode[i].number
        guess[i].position = true 
        @passcode[i].position = true 
      end
    end
    guess
  end

  # check each digit in passcode against every digit in guess
  # skip matches that have the same index or have already been matched
  def name_only_check(guess)
    4.times do |i|
      4.times do |j|
        if guess[i].number == @passcode[j].number 
          unless @passcode[i].position || @passcode[i].name_only
            unless i == j
              guess[i].name_only = true
            end
          end
        end
      end
    end
    guess
  end

  def all_correct?
    bool = true
    @passcode.each { |digit| bool = false unless digit.position }
    bool
  end

  #TODO: guess has an empty passcode
  # compare two passcodes and return a string
  def check_passcode(guess)
    guess = position_check(guess)
    guess = name_only_check(guess)
    result = "#{number_correct_position}: Correct postion.\n#{number_correct_name}: Correct digit.\n\n"
    if guess.all_correct?
      return Result.new(result, true)
    else
      return Result.new(result, false)
    end  
  end

  # return a guess with the correct digit if it's guessed it before and a rand otherwise
  def computer_guess(passcode)
    guess = Passcode.new
    4.times do |i| 
      if passcode[i].position
        guess.passcode.push(Digit.new(passcode[i].number))
      else
        guess.passcode.push(Digit.new(rand(1..6).to_s))
      end
    end
    guess
  end
end

class Digit
  attr_accessor :number, :position, :name_only
  def initialize(number)
    @number = number
    @position = false
    @name_only = false
  end

  def number
    @number
  end
end

class Result
  def initialize(result, victory)
    @result = result
    @victory = victory
  end
  def victory?
    @victory
  end
end

def get_decision(a,b)
  loop do
    response = gets.chomp
    if response == a
      return true
    elsif response == b
      return false
    else
      puts "Please type '#{a}' or '#{b}'."
    end
  end
end

loop do
  Mastermind.new
  puts "Play again? (y/n)"
  break unless get_decision('y','n')
end
