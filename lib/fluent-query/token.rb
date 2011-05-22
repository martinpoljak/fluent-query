# encoding: utf-8

module FluentQuery
                
     ##
     # Represents general query token.
     #
     
     class Token

        ##
        # Name of the token.
        #
        
        @_name

        ##
        # Alias of the token.
        #
        
        @_alias

        ##
        # Arguments for the token.
        #
        
        @arguments
        attr_reader :arguments
        
        ##
        # Initializes token.
        #

        public
        def initialize(name, arguments)
            @_name = name
            @arguments = arguments
        end

        ##
        # Returns token name.
        #

        public
        def name
            if @_alias
                return @_alias
            else
                return @_name
            end
        end
        
        ##
        # Returns original token name.
        #

        public
        def original_name
            @_name
        end

        ##
        # Sets alias for token.
        #

        public
        def alias=(_alias)
            @_alias = _alias
        end
        
     end
     
end
