require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov/omniauth.lcov'
end
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ]
)

SimpleCov.start do
    add_filter ['/spec/', '/vendor/', 'strategy_macros.rb']
    minimum_coverage(92.5)
    maximum_coverage_drop(0.05)
end