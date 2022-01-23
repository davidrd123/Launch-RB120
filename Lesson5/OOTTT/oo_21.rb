=begin
Twenty-One is a card game consisting of a dealer and a player, where the participants 
try to get as close to 21 as possible without going over.

Here is an overview of the game:
- Both participants are initially dealt 2 cards from a 52-card deck.
- The player takes the first turn, and can "hit" or "stay".
- If the player busts, he loses. If he stays, it's the dealer's turn.
- The dealer must hit until his cards add up to at least 17.
- If he busts, the player wins. If both player and dealer stays, then the highest total wins.
- If both totals are equal, then it's a tie, and nobody wins.

Nouns: card, player, dealer, participant, deck, game, total
Verbs: deal, hit, stay, busts

Player
- hit
- stay
- busted?
- total
Dealer
- hit
- stay
- busted?
- total
- deal (should this be here, or in Deck?)
Participant
Deck
- deal (should this be here, or in Dealer?)
Card
Game
- start


=end
require 'pry'

module Hand
  attr_accessor :cards
end

class Participant
  # what goes in here? all the redundant behaviors from Player and Dealer?
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
    @cards = []
  end

  def stay
  end

  def busted?
    total > 21
  end

  def total
    # definitely looks like we need to know about "cards" to produce some total
    values = @cards.map { |card| card[1] }

    sum = 0
    values.each do |value|
      if value == "A"
        sum += 11
      elsif value.to_i == 0 # J, Q, K
        sum += 10
      else
        sum += value.to_i
      end
    end

    # correct for Aces
    values.select { |value| value == "A" }.count.times do
      sum -= 10 if sum > 21
    end

    sum
  end
end

class Player < Participant
  include Hand

  def hit
  
  end
end

class Dealer < Participant
  include Hand

  def hit

  end

end

class Deck
  attr_reader :cards

  def initialize
    # obviously, we need some data structure to keep track of cards
    # array, hash, something else?
    @cards = Card::SUITS.product(Card::VALUES).shuffle
  end

  def reset
    @cards = Card::SUITS.product(Card::VALUES).shuffle
  end

  def deal(player)
    # does the dealer or the deck deal?
    player.cards << @cards.pop
  end

  def to_s
    @cards
  end
end

class Card
  SUITS = ['H', 'D', 'S', 'C']
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  
  def initialize(suit, value)
    # what are the "states" of a card?
    @suit = suit
    @value = value
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def reset
    self.deck = Deck.new
    player.cards = []
    dealer.cards = []
  end

  def prompt(msg)
    puts "=> #{msg}"
  end

  def show_result
    result = detect_result
  
    case result
    when :player_busted
      prompt "You busted! Dealer wins!"
    when :dealer_busted
      prompt "Dealer busted! You win!"
    when :player
      prompt "You win!"
    when :dealer
      prompt "Dealer wins!"
    when :tie
      prompt "It's a tie!"
    end
  end

  def detect_result
    player_total = @player.total
    dealer_total = @dealer.total
  
    if player_total > 21
      :player_busted
    elsif dealer_total > 21
      :dealer_busted
    elsif dealer_total < player_total
      :player
    elsif dealer_total > player_total
      :dealer
    else
      :tie
    end
  end

  def player_turn
    loop do
      player_turn = nil
      loop do
        prompt "Would you like to (h)it or (s)tay?"
        player_turn = gets.chomp.downcase
        break if ['h', 's'].include?(player_turn)
        prompt "Sorry, must enter 'h' or 's'."
      end

      if player_turn == 'h'
        @deck.deal(@player)
        prompt "You chose to hit!"
        prompt "Your cards are now: #{@player.cards}"
        prompt "Your total is now: #{@player.total}"
      end

      break if player_turn == 's' || @player.busted?
    end
  end

  def dealer_turn
    prompt "Dealer turn..."

    loop do
      break if @dealer.total >= 17

      prompt "Dealer hits!"
      @deck.deal(@dealer)
      prompt "Dealer's cards are now: #{@dealer.cards}"
    end

  end

  def deal_cards
    2.times do 
      @deck.deal(@player)
      @deck.deal(@dealer)
    end
  end

  def show_initial_cards
    prompt "Dealer has #{@dealer.cards[0]} and ?"
    prompt "You have: #{@player.cards[0]} and #{@player.cards[1]}, for a total of #{@player.total}"
  end

  def play_again?
    puts "-------------"
    prompt "Do you want to play again? (y or n)"
    answer = gets.chomp
    answer.downcase.start_with?('y')
  end

  def reset_game

  end

  def start
    # p @deck
    loop do
      system 'clear'
      deal_cards
      show_initial_cards

      player_turn
      dealer_turn

      if @dealer.busted?
        prompt "Dealer total is now: #{@dealer.total}"
        display_result(@dealer.cards, @player.cards)
        play_again? ? next : break
      else
        prompt "Dealer stays at #{@dealer.total}"
      end

      # both player and dealer stays - compare cards!
      puts "=============="
      prompt "Dealer has #{@dealer.cards}, for a total of: #{@dealer.total}"
      prompt "Player has #{@player.cards}, for a total of: #{@player.total}"
      puts "=============="

      show_result

      reset

      break unless play_again?
    end
  end
end

Game.new.start