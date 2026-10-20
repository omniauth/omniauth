D = Steep::Diagnostic

target :lib do
  signature 'sig', 'steep/shims'
  check 'lib'

  library 'singleton', 'uri'

  configure_code_diagnostics(D::Ruby.strict)
end
