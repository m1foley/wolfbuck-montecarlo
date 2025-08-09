#!/usr/bin/env ruby

WOLFBUCK_RANGE_PER_WEEK = 6..10
WINNERS_PER_DRAWING = 15
OTHER_KIDS = (1..80).map(&:to_s)
RAFFLES_PER_YEAR = 36
ITERATIONS = 500
OUR_STUDENT = Object.new

def run_simulations
  $stdout.puts "Wolf Buck Monte Carlo"
  $stdout.puts "Simulations: #{ITERATIONS}\n\n"
  $stdout.puts "Prizes per year:\n"

  run_simulation("Turn in immediately") { 1 }

  run_simulation("Turn in every 2 weeks") do |raffle_number|
    ((raffle_number - 1) % 2 == 0) ? 2 : 0
  end

  run_simulation("Save until end of month") do |raffle_number|
    ((raffle_number - 3) % 4 == 0) ? 4 : 0
  end

  run_simulation("Save until end of year") do |raffle_number|
    (raffle_number == RAFFLES_PER_YEAR - 1) ? RAFFLES_PER_YEAR : 0
  end
end

def run_simulation(description, &block)
  $stdout.print "#{description}: "
  prizes = ITERATIONS.times.sum { simulate_year(&block) }
  avg_prizes_per_year = prizes.to_f / ITERATIONS
  $stdout.puts avg_prizes_per_year.round
end

def simulate_year(&block)
  RAFFLES_PER_YEAR.times.count do |raffle_number|
    weekly_wolfbucks_multiplier = block.call(raffle_number)
    our_wolfbucks_per_drawing = (WOLFBUCK_RANGE_PER_WEEK.min * weekly_wolfbucks_multiplier)..(WOLFBUCK_RANGE_PER_WEEK.max * weekly_wolfbucks_multiplier)
    wolfbucks = generate_wolfbucks(our_wolfbucks_per_drawing)
    winners = pick_winners(wolfbucks)
    winners.include?(OUR_STUDENT)
  end
end

def generate_wolfbucks(our_wolfbucks_per_drawing)
  wolfbucks = []
  wolfbucks += [OUR_STUDENT] * our_wolfbucks_per_drawing.to_a.sample
  OTHER_KIDS.each do |kid|
    wolfbucks += [kid] * WOLFBUCK_RANGE_PER_WEEK.to_a.sample
  end
  wolfbucks.shuffle
end

def pick_winners(wolfbucks)
  winners = []
  while winners.size < WINNERS_PER_DRAWING
    while (winner = wolfbucks.shift)
      unless winners.include?(winner)
        winners << winner
        break
      end
    end
  end
  winners
end

run_simulations
