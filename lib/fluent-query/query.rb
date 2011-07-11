# encoding: utf-8
require "fluent-query/queries/abstract"
require "fluent-query/queries/compiled"
require "fluent-query/queries/prepared"
require "fluent-query/token"
require "fluent-query/tokens/raw"

module FluentQuery
        
     ##
     # Represents single query.
     #
     
     class Query < FluentQuery::Queries::Abstract

        ##
        # Tokens stack.
        #

        @stack
        attr_reader :stack

        ##
        # Initializes query.
        #

        public
        def initialize(connection)
            super(connection)
            @stack = [ ]
        end
        
        ##
        # Catches missing methods calls. Converts them to tokens.
        #

        public
        def method_missing(sym, *args, &block)
            
            self.push_token(sym, args)
            driver = @connection.driver
            conditionally = driver.execute_conditionally(self, sym, *args, &block)

            if not conditionally.nil?
                result = conditionally
            else
                result = self
            end
            
            return result
        end

        ##
        # Pushes new token according to specified arguments to the stack.
        #
        
        public
        def push_token(name, arguments)
            @stack << FluentQuery::Token::new(name, arguments)
        end

        ##
        # Pushes raw token to the query, so free unassociated query string.
        #

        public
        def query(*args)
            @stack << FluentQuery::Tokens::Raw::new(args)
            return self
        end

        ##
        # Returns type of the query, so name of the first token
        # in the stack.
        #

        public
        def type
            self.stack.first.name.to_sym
        end

        ##
        # Builds the query.
        #

        public
        def build
            @connection.driver.build_query(self)
        end
        
        alias :"build!" :build

        ##
        # Compiles query.
        # Returns compiled query object.
        #
        
        public
        def compile
            FluentQuery::Queries::Compiled::new(@connection, self)
        end
        
        alias :"compile!" :compile

        ##
        # Prepares query.
        # Returns prepared query object.
        #
        
        public
        def prepare
            FluentQuery::Queries::Prepared::new(@connection, self)
        end
        
        alias :"prepare!" :prepare

    end
end
