#!/usr/bin/env ruby

WOLFBUCK_RANGE_PER_WEEK = 4..10
WINNERS_PER_DRAWING = 15
OTHER_KIDS = (1..80).map(&:to_s)
RAFFLES_PER_YEAR = 36
MONTE_CARLO_SIMULATIONS = 1000

def run_simulations
  $stdout.puts "Simulations: #{MONTE_CARLO_SIMULATIONS}\n\n"
  $stdout.puts "Prizes per year:\n"

  # strategy 1: turn in immediately
  run_simulation("Turn in immediately") { 1 }

  # strategy 2: save until end of the month
  run_simulation("Save until end of month") do |raffle_number|
    ((raffle_number - 3) % 4 == 0) ? 4 : 0
  end

  # strategy 3: save until end of the school year
  run_simulation("Save until end of year") do |raffle_number|
    (raffle_number == RAFFLES_PER_YEAR - 1) ? RAFFLES_PER_YEAR : 0
  end
end

def run_simulation(description, &block)
  $stdout.print "#{description}: "
  prizes = MONTE_CARLO_SIMULATIONS.times.sum do
    simulate_year(&block)
  end
  avg_prizes_per_year = prizes.to_f / MONTE_CARLO_SIMULATIONS
  $stdout.puts avg_prizes_per_year
end

def simulate_year(&block)
  RAFFLES_PER_YEAR.times.count do |raffle_number|
    weekly_wolfbucks_multiplier = block.call(raffle_number)
    madeline_wolfbucks_per_drawing = (WOLFBUCK_RANGE_PER_WEEK.min * weekly_wolfbucks_multiplier)..(WOLFBUCK_RANGE_PER_WEEK.max * weekly_wolfbucks_multiplier)
    wolfbucks = generate_wolfbucks(madeline_wolfbucks_per_drawing)
    winners = pick_winners(wolfbucks)
    winners.include?("Madeline")
  end
end

def generate_wolfbucks(madeline_wolfbucks_per_drawing)
  wolfbucks = []
  wolfbucks += ["Madeline"] * madeline_wolfbucks_per_drawing.to_a.sample
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
