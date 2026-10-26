# frozen_string_literal: true

# Duel's configuration: https://github.com/sferik/duel-ruby/blob/main/docs/configuration.md
#
# Duel follows conventions, so set only what differs: benchmarks are in
# duel/**/*_duel.rb, each version's lib/ is first on the load path, a
# change is compared when it touches lib/ or ext/, and releases are
# tagged v*.
Duel.configure do |c|
  # The library each version's workers require (from the gemspec, unless
  # this says otherwise).
  # c.library = "omniauth"

  # Compare a change to only the Perf workflow too.
  c.watch += %w[.github/workflows/perf.yml]
end
