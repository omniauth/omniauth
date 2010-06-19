module OmniAuth
  
  # Support for testing OmniAuth strategies.
  module Test
    
    autoload :PhonySession,   'omniauth/test/phony_session'
    autoload :StrategyMacros, 'omniauth/test/strategy_macros'
    
  end
  
end
