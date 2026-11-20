# frozen_string_literal: true

# Duel's configuration: https://github.com/sferik/duel-ruby/blob/main/docs/configuration.md
#
# Duel follows conventions, so set only what differs: benchmarks are in
# duel/**/*_duel.rb, each version's lib/ is first on the load path, a
# change is compared when it touches lib/ or ext/ (or the benchmarks, or
# this file), and releases are tagged v*.
Duel.configure do |c|
  # The library each version's workers require (from the gemspec, unless
  # this says otherwise).
  # c.library = "omniauth"

  # Compare a change to only the Perf workflow too.
  c.watch += %w[.github/workflows/perf.yml]

  # Which runs a regression fails: :every_run, or :pull_requests, for a
  # project where people push to main directly (on GitHub Actions, another
  # run warns and passes, and a pushed commit gets the comment instead).
  # c.fail_on = :every_run

  # A label that accepts a regression in a pull request, for a change
  # that's slower on purpose (nil for none).
  # c.accept_label = 'duel: accept'

  # A push is compared with the last commit Duel passed, which a branch
  # marks (duel/passed/master for master), not the commit before it, so
  # slowdowns too small for any one push to fail add up until they fail
  # one. To accept a regression after it's pushed, move that branch:
  # git push origin master:duel/passed/master.
  c.push_base = :last_passed
end
