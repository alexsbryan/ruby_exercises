class Hangman
  attr_accessor :word_to_guess, :creator, :player, :hangman_array, :letters_guessed
  #creator or player should be human or computer
  def initialize creator, player
    #@creator = ComputerPlayer.new
    @creator = creator
    #@word_to_guess = @creator.secret_word
    #@player = HumanPlayer.new
    @player = player
    @hangman_array = []
    @letters_guessed = []
  end

  def ask_secret_length
    self.creator.provide_secret_length
  end

  def create_hangman_array
    self.hangman_array = Array.new (self.ask_secret_length)
  end

  def play
    indices_from_player = []
    create_hangman_array

    until won?
      self.letters_guessed << self.player.guess(self.hangman_array)
      indices_from_player = self.creator.handle_guess_response(self.letters_guessed.last)

      unless indices_from_player.empty?

        indices_from_player.each do |index|
          self.hangman_array[index] = self.letters_guessed.last
        end
        self.letters_guessed.pop
      end

      p self.hangman_array.flatten

      return puts "You lose! The word was" if self.letters_guessed.length > 10
    end
    puts "You win"
  end

  def won?
    @hangman_array.none?{ |letter| letter.nil? }
  end
end


class HumanPlayer

  def guess hangman_array
    puts "Guess a letter dude.."
    gets.chomp
  end

  #how many letters in my word?
  def provide_secret_length
    puts "Give how many letters are in your word!"
    gets.chomp.to_i
  end

  def handle_guess_response guess
    puts "Is #{guess} in your word? (y or n)"
    letter_available = gets.chomp

    if letter_available == "y"
      puts "What is the indices of the letter in the word? (i.e. 'n' in banana is: 2, 4)"
      correct_letter_index = gets.chomp.split(',').map(&:to_i)
    else
      []
    end
  end

end


class ComputerPlayer

  attr_accessor :dictionary, :guessed_letters, :smart_dictionary
  attr_reader :secret_word

  RANDOM_ARRAY = ("a".."z").to_a

  def initialize
    @dictionary = []
    readfile_line
    @secret_word = secret_words
    @guessed_letters = []
    @smart_dictionary = @dictionary
  end

  def readfile_line
    File.foreach('dictionary.txt') do |line|
      @dictionary << line.chomp
    end
  end

  def secret_words
    self.dictionary.sample(1)[0]
  end

  def provide_secret_length
    secret_word.length
  end

  def handle_guess_response guess
    temp_array = @secret_word.split('')

    if temp_array.include? guess
      letter_location(guess)
    else
      []
    end

  end

  def letter_location letter
    secret_word_split = @secret_word.split('')
    matched_array = []

    secret_word_split.each_with_index do |secret_letter, index|
      matched_array << index if letter == secret_letter
    end
    matched_array
  end

  def guess hangman_array
    #dumb_guess_ai
    smart_guess_ai(hangman_array)
  end

  def dumb_guess_ai
    random_letter = RANDOM_ARRAY.sample(1)
    while @guessed_letters.include? random_letter
      random_letter = RANDOM_ARRAY.sample(1)
    end

    @guessed_letters << random_letter
    @guessed_letters.last
  end

  def smart_guess_ai hangman_array

    @guessed_letters |= hangman_array

    self.smart_dictionary.select! { |word| word.length == hangman_array.length }

    hangman_array.each_with_index do |letter, index|
      next if letter.nil?
      self.smart_dictionary.delete_if do |dictionary_word|
        dictionary_word[index] != letter
      end
    end

    smart_dictionary_big_join = self.smart_dictionary.join('')

    smart_key_hash = Hash.new(0)
    smart_dictionary_big_join.split("").each do |key|
      smart_key_hash[key] += 1 unless @guessed_letters.include?(key)
    end

    smart_key_hash = smart_key_hash.sort_by {|_key, value| value}
    p smart_key_hash
    p hangman_array
    @guessed_letters << smart_key_hash.last[0]
    smart_key_hash.last[0]
  end

end


a = ComputerPlayer.new
b = HumanPlayer.new
g = Hangman.new(b,a)
g.play