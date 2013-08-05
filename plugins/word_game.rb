require 'cinch'

class Cinch::Plugins::WordGame
  include Cinch::Plugin

  def initialize(*args)
    super
    @dict = Dictionary.from_file("/etc/dictionaries-common/words")
  end

  def response(m)
    Response.new(m, @game)
  end

  match(/word start/, method: :start)
  def start(m)
    @game = Game.new(@dict)
    response(m).start_game
  end

  match(/word cheat/, method: :cheat)
  def cheat(m)
    response(m).cheat if @game
  end

  match(/guess (\S+)/, method: :guess)
  def guess(m, word)
    if @game
      if @game.guess(word, response(m))
        @game = nil
      end
    else
      response(m).game_not_started
    end
  end

  class Game
    attr_reader :number_of_guesses, :last_guess, :word

    def initialize(dictionary)
      @dict = dictionary
      @word = Word.new(@dict.random_word)
      puts "Word is #{@word}"
      @number_of_guesses = 0
    end

    def guess(word, response)
      @number_of_guesses += 1
      @last_guess = word
      if @dict.word_valid?(word)
        guess_correct?(word, response)
      else
        response.invalid_word
        false
      end
    end

    def number_of_guesses_phrase
      if number_of_guesses == 1
        "1 guess"
      else
        "#{number_of_guesses} guesses"
      end
    end

  protected
    def guess_correct?(word, response)
      if @word == word
        response.game_won
        true
      else
        response.wrong_word(@word.before_or_after(word))
        false
      end
    end
  end

  class Response
    def initialize(output, game)
      @game = game
      @output = output
      @user = output.user
    end

    def game_not_started
      output.reply("I haven't started a word game yet. Use `!word start` to start one.")
    end

    def start_game
      output.reply("Starting a new word game. Make a guess.")
    end

    def game_won
      output.reply("Yes, that's the word! Congratulations, #{user} wins! You had #{game.number_of_guesses_phrase}.")
    end

    def cheat
      output.reply "You want to cheat after #{game.number_of_guesses}? Fine. The word is #{game.word}. #{user}: you suck."
    end

    def wrong_word(before_or_after)
      output.reply(%Q{My word comes #{before_or_after} "#{game.last_guess}". You've had #{game.number_of_guesses} guesses.})
    end

    def invalid_word
      output.reply(%Q{#{user}: "#{game.last_guess}" isn't a word. At least as far as I know.})
    end

  protected
    attr_reader :user, :output, :game
  end

  class Dictionary
    def initialize(words)
      @words = words
    end

    def self.from_file(filename)
      words = []
      File.foreach(filename) do |word|
        if word[0] == word[0].downcase
          words << word.strip.gsub(/'.*/, '')
        end
      end
      self.new(words)
    end

    def random_word
      @words.sample
    end

    def word_valid?(word)
      @words.include? word
    end
  end

  class Word
    attr_accessor :word

    def initialize(word)
      @word = word
    end

    def before?(other_word)
      @word < other_word.downcase
    end

    def before_or_after(other_word)
      before?(other_word) ? "before" : "after"
    end

    def ==(other_word)
      @word == other_word
    end

    def to_s
      @word
    end
  end

end
