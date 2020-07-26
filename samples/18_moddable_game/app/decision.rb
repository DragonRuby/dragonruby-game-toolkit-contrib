# Hey there! Welcome to Four Decisions. Here is how you
# create your decision tree. Remove =being and =end from the text to
# enable the game (just save the file). Change stuff and see what happens!

def game
  {
    starting_decision: :stormy_night,
    decisions: {
      stormy_night: {
        description: 'It was a dark and stormy night. (storyline located in decision.rb)',
        option_one: {
          description: 'Go to sleep.',
          decision: :nap
        },
        option_two: {
          description: 'Watch a movie.',
          decision: :movie
        },
        option_three: {
          description: 'Go outside.',
          decision: :go_outside
        },
        option_four: {
          description: 'Get a snack.',
          decision: :get_a_snack
        }
      },
      nap: {
        description: 'You took a nap. The end.',
        option_one: {
          description: 'Start over.',
          decision: :stormy_night
        }
      }
    }
  }
end
