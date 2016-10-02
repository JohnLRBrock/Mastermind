# John Brock
# 2016/10/1
# The Odin Project
# Mastermind

# supplies structure for the game
class Mastermind
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
    puts "----------------------\n\n"  \
         "    WELCOME HUMAN\n----------------------\n\n"\
         'Do you want to the be the code maker or code breaker? (m/b)'
    get_decision('m', 'b')
  end

  def victory
    @won = true
    "That's right! You guessed all four! You won :D!\n"
  end

  def computer_victory
    @won = true
    "The computer guessed correct! The Computer wins!\n"
  end

  def defeat(passcode)
    @lost = true
    'That was your last turn! You lost D: ' \
    "The password was #{passcode.passcode}.\n"
  end

  def computer_defeat
    @lost = true
    "That was the computer's last turn! The computer loses!\n"
  end

  def human_guesser
    passcode = create_passcode
    turn(passcode) until @lost || @won
  end

  def get_code
    code = Passcode.new
    loop do
      user_code = gets.chomp.chars
      if user_code.size == code.size && illegal_characters?(user_code)
        4.times { |i| code.add(Digit.new(user_code[i])) }
        break
      elsif user_code.size != code.size
        puts "Your guess must have #{@size} characters."
      else
        puts 'Please only use the numbers 1-6 in your answers.'
      end
    end
    code
  end

  def turn(passcode)
    puts "Turn #{@turn}"
    puts 'Guess the passcode.'
    guess = get_code
    check_result = passcode.check_passcode(guess)
    puts check_result.result
    puts victory if check_result.victory?
    @turn += 1
    puts defeat(passcode) if @turn == 13
  end

  def computer_guesser
    puts 'Type your secret passcode.'
    passcode = get_code
    passcode = computer_turn(passcode) until @lost || @won
  end

  def computer_turn(passcode)
    puts "Turn #{@turn}"
    guess = computer_guess(passcode)
    check_result = passcode.check_passcode(guess)
    puts check_result.result
    puts computer_victory if check_result.victory?
    @turn += 1
    puts computer_defeat if @turn == 13
    passcode
  end

  def create_passcode
    passcode = Passcode.new
    4.times { passcode.add(Digit.new(rand(1..6).to_s)) }
    passcode
  end

  def illegal_characters?(guess)
    legal_digits = true
    guess.each { |digit| legal_digits = false unless ('1'..'6').cover?(digit) }
    legal_digits
  end

  # computer remembers correctly guess digits
  def computer_guess(passcode)
    guess = Passcode.new
    4.times do |i|
      if passcode[i].position
        guess.add(Digit.new(passcode[i].number))
      else
        guess.add(Digit.new(rand(1..6).to_s))
      end
    end
    puts "The computer's guess is #{guess.passcode}"
    guess
  end
end

# the codes used in the game
class Passcode
  attr_reader :size
  attr_accessor :passcode

  def initialize
    @passcode = []
    @size = 4
  end

  def passcode
    return puts 'The Passcode is empty' if @passcode.empty?
    code = []
    @passcode.each { |digit| code.push(digit.number) }
    code.join(', ')
  end

  def [](ind)
    @passcode[ind]
  end

  def []=(ind, value)
    @passcode[ind] = value
  end

  def add(digit)
    @passcode.push(digit)
  end

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
            guess[i].name_only = true unless i == j
          end
        end
      end
    end
    guess
  end

  def all_correct?
    bool = true
    @passcode.each { |digit| bool = false unless digit.position? }
    bool
  end

  def correct_positions
    count = 0
    @passcode.each { |digit| count += 1 if digit.position? }
    count
  end

  def correct_names
    count = 0
    @passcode.each { |digit| count += 1 if digit.name_only? }
    count
  end

  # compare two passcodes and return a string
  def check_passcode(guess)
    guess = position_check(guess)
    guess = name_only_check(guess)
    result = "#{guess.correct_positions}: Correct position.\n" \
             "#{guess.correct_names}: Correct digit.\n\n"
    return Result.new(result, true) if guess.all_correct?
    Result.new(result, false)
  end
end

# digits in a code
class Digit
  attr_reader :number

  def initialize(number)
    @number = number
    @position = false
    @name_only = false
  end

  def position?
    @position
  end

  def name_only?
    @name_only
  end
end

# Result is a data structure to hold information about the results of a check
class Result
  attr_reader :result

  def initialize(result, victory)
    @result = result
    @victory = victory
  end

  def victory?
    @victory
  end
end

def get_decision(a, b)
  loop do
    response = gets.chomp
    return true if response == a
    return false if response == b
    puts "Please type '#{a}' or '#{b}'."
  end
end

loop do
  Mastermind.new
  puts 'Play again? (y/n)'
  break unless get_decision('y', 'n')
end
