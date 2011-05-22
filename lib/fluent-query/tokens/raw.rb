# encoding: utf-8
require "fluent-query/token"

module FluentQuery
    module Tokens
    
         ##
         # Represents query raw token.
         #
         
         class Raw < FluentQuery::Token
         
            ##
            # Initializes token.
            #

            public
            def initialize(arguments)
                super(:" ", arguments)
            end
            
         end
         
     end
 end

