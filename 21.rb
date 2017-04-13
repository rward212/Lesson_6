=begin
pseudocode:
create a deck
shuffle the deck
deal two cards to player and dealer
show player his cards
show player one of the dealer's cards
calculate sum of card values

V player turn
player makes decision hit or stay?
if player hit, deal player another card and show
if player bust, end game
if player gets 21, end game
if player stay, end turn

V Dealer turn
dealer shows the hidden card
calculate dealer score
if score is less than 17 then hit
  -if new hand is greater than 21, bust
  -if new hand equals 21, then win
if score is greater than 17, stay
dealer turn ends

decide who won (if winner)
-need to compare player hand with dealers hand
player with higher hand wins
if hands are =, then tie
=end

# W is the max value that non-ace cards can total before an Ace must = 1 (if just 1 Ace)
W = 10

# X is the number the dealer must exceed
X = 17

# Y is the number that must not be exceeded
Y = 21

# Z is the max value that non-ace cards can total before and Ace must = 1
Z = 11

require "pry"

def prompt(message)
  puts "=> #{message}"
end

# initializes a new deck
def initialize_deck
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  suite = ["Spades", "Hearts", "Diamonds", "Clubs"]
  values.product(suite).shuffle
end

# removes card from deck and adds it to receiver's hand
def deal_card(deck, receiver)
  receiver << deck.pop
end

# shows one of the receiver's cards
def show_card(receiver)
  "#{receiver[0][0]} of #{receiver[0][1]}"
end

# shows all the receiver's cards
def show_all_cards(receiver, delimiter = ', ', word = "and")
  # temp_var is an array of strings(cards)
  temp_var = receiver.map { |element| element.join(" of ") }
  case temp_var.size
  when 0 then ''
  when 1 then temp_var.first.to_s
  when 2 then temp_var.join(" #{word} ").to_s
  else
    temp_var[-1] = "#{word} #{temp_var.last}"
    temp_var.join(delimiter).to_s
  end
end

# returns a new nested array with facecards renamed to 10
def convert_facecards(receiver)
  receiver.map do |element|
    case element[0]
    when "J" then 10
    when "Q" then 10
    when "K" then 10
    when "A" then "A"
    else element[0].to_i
    end
  end
end

# returns an array with aces changed to 1
def change_aces_to_1(receiver)
  receiver.map! do |val|
    if val == "A"
      1
    else
      val
    end
  end
  receiver.reduce(:+)
end

# returns an array with aces changed to 11
def change_aces_to_11(receiver)
  receiver.map! do |val|
    if val == "A"
      11
    else
      val
    end
  end
  receiver.reduce(:+)
end

# returns value of a hand with just one ace
def hand_with_one_ace(receiver)
  without_aces = receiver.select { |char| char != "A" }
  if without_aces.sum > W
    change_aces_to_1(receiver)
  else
    change_aces_to_11(receiver)
  end
end

# returns value of a hand with multiple aces
def hand_with_multiple_aces(receiver)
  without_aces = receiver.select { |char| char != "A" }
  if without_aces.sum < Z
    receiver[receiver.find_index("A")] = 11
  end
  change_aces_to_1(receiver)
end

# returns value of hand
def calculate_sum(receiver)
  tally = convert_facecards(receiver)
  all_the_aces = tally.select { |char| char == "A" }

  # if you have multiple aces
  if all_the_aces.length > 1
    hand_with_multiple_aces(tally)

  # if you only have 1 ace
  elsif all_the_aces.length == 1
    hand_with_one_ace(tally)

  # if you don't have any aces
  else
    tally.reduce(:+)
  end
end

def twenty_one?(receiver)
  if calculate_sum(receiver) == Y
    true
  else
    false
  end
end

def bust?(receiver)
  if calculate_sum(receiver) > Y
    true
  else
    false
  end
end

# gets response from player and potentially deals a card to player if player hits
def player_choice(deck, receiver)
  loop do
    prompt("Would you like to (h)it or (s)tay?")
    response = gets.chomp
    if response == "h"
      deal_card(deck, receiver)
      prompt("Your cards are: #{show_all_cards(receiver)}")
    elsif response == "s"
      break
    else
      prompt("I'm sorry, that is not a valid choice. Please try again.")
    end
  end
end


def player_loop(deck, receiver, other_receiver)
  sleep 1
  prompt("The dealer's cards are: #{show_card(other_receiver)}")
  sleep 2
  prompt("Your cards are: #{show_all_cards(receiver)}")
  sleep 1
  player_choice(deck, receiver)
end

def dealer_loop(deck, receiver)
  loop do
    sleep 1
    prompt("The dealer's cards are: #{show_all_cards(receiver)}")
    sleep 1
    if bust?(receiver)
      break
    elsif calculate_sum(receiver) >= X
      break
    else
      deal_card(deck, receiver)
    end
  end
end

# compares sum of players and dealer's cards and reports who wins
def report_score(player1, dealer1)
  prompt("Player's score: #{player1}")
  prompt("Dealer's score: #{dealer1}")
end

# prints the winner of noone busts.
def declare_overall_winner(player1, player2)
  if player1 == 5
    prompt("You win the series!")
  elsif player2 == 5
    prompt("Dealer wins the series!")
  elsif player1 == 5 && player2 == 5
    prompt("You tied the series!")
  else
    prompt("Your final score: #{player1}")
    prompt("Dealer final score: #{player2}")
  end
end
#####################################################################
loop do
    dealerscore = 0
    playerscore = 0
  loop do
    player = []
    dealer = []
    deck = initialize_deck

    system 'clear'
    puts "Dealing cards..."

    2.times do
      deal_card(deck, player)
      deal_card(deck, dealer)
    end

   
    player_loop(deck, player, dealer)

    if bust?(player)
      dealerscore += 1
      prompt("You busted!")
    else
      dealer_loop(deck, dealer)
      if bust?(dealer)
        prompt("Dealer Busted. You win.")
        playerscore += 1
      elsif calculate_sum(dealer) > calculate_sum(player)
        prompt("Dealer wins.")
        dealerscore += 1
      elsif calculate_sum(dealer) < calculate_sum(player)
        playerscore += 1
        prompt("You win.")
      else
        prompt("It's a tie!")
      end
    end

    report_score(playerscore, dealerscore)
    break if playerscore == 5 || dealerscore == 5
    prompt("Are you ready to play the next round? (y/n)")
    answer = gets.chomp.downcase
    break if answer == "n"
  end

  declare_overall_winner(playerscore, dealerscore)
  sleep 1
  prompt("Would you like to play again? (y/n)")
  answer = gets.chomp
  break if answer == "n"
end
