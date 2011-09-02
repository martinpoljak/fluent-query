# encoding: utf-8
require "abstract"

module FluentQuery
        
     ##
     # Represents abstract query driver.
     # @abstract
     #
     
     class Driver

        ##
        # Holds connection associated to this driver instance.
        #

        @connection
        attr_reader :connection
        
        ##
        # Initializes driver.
        # 

        public
        def initialize(connection)
            if self.instance_of? FluentQuery::Driver
                not_implemented
            end

            @connection = connection
        end

        #####

        ##
        # Indicates, method is relevant for the driver.
        # @abstract
        #

        public
        def relevant_method?(name)
            not_implemented
        end


        ##
        # Indicates token is known.
        # @abstract
        #

        public
        def known_token?(group, token_name)
            not_implemented
        end

        ##
        # Indicates, token is operator.
        # @abstract
        #

        public
        def operator_token?(token_name)
            not_implemented
        end

        ##
        # Returns operator string according to operator symbol.
        # @abstract
        #

        public
        def quote_operator(operator)
            not_implemented
        end

        ##
        # Returns correct equality operator for given datatype.
        #
        # Must handle two modes:
        #   * "assigning" which classicaly keeps for example the '=' operator,
        #   * "comparing" which sets for example 'IS' operator for booleans.
        #
        # @abstract
        #

        public
        def quote_equality(datatype, mode = :comparing)
            not_implemented
        end

        ##
        # Indicates which query subclass to use.
        # @abstract
        #

        public
        def query_class
            not_implemented
        end

        ##
        # Builds given query.
        # @abstract
        #

        public
        def build_query(query)
            not_implemented
        end
        
        ##
        # Returns preparation placeholder according to given 
        # library placeholder.
        #
        # @abstract
        #
        
        public
        def quote_placeholder(placeholder)
            not_implemented
        end


        ##### QUOTING

        ##
        # Quotes string.
        # @abstract
        #

        public
        def quote_string(string)
            not_implemented
        end

        ##
        # Quoting integer.
        # @abstract
        #

        public
        def quote_integer(integer)
            not_implemented
        end

        ##
        # Quotes float.
        # @abstract
        #

        public
        def quote_float(float)
            not_implemented
        end

        ##
        # Quotes field by field quoting.
        # @abstract
        #

        public
        def quote_identifier(field)
            not_implemented
        end

        ##
        # Creates system-dependent NULL.
        # @abstract
        #

        public
        def null
            not_implemented
        end

        ##
        # Quotes system-dependent boolean value.
        # @abstract
        #

        public
        def quote_boolean(boolean)
            not_implemented
        end

        ##
        # Quotes system-dependent date value.
        # @abstract
        #

        public
        def quote_date_time(date)
            not_implemented
        end

        ##
        # Quotes system-dependent subquery.
        # @abstract
        #

        public
        def quote_subquery(subquery)
            not_implemented
        end



        ##### EXECUTING

        ##
        # Opens the connection.
        #
        # It's lazy, so it will open connection before first request through
        # {@link native_connection()} method.
        #
        # @abstract
        #

        public
        def open_connection(settings)
            not_implemented
        end

        ##
        # Returns native connection.
        # @abstract
        #

        public
        def native_connection
            not_implemented
        end

        ##
        # Closes the connection.
        # @abstract
        #

        public
        def close_connection!
            not_implemented
        end

        ##
        # Executes the query.
        # @abstract
        #

        public
        def execute(query)
            not_implemented
        end

        ##
        # Executes the query and returns count of the changed/inserted rows.
        # @abstract
        #

        public
        def do(query)
            not_implemented
        end
        
        ##
        # Generates prepared query. Should be noted, if driver doesn't
        # support query preparing, it should be +not_implemented+ and
        # unimplemented.
        #
        # @abstract
        #
        
        public
        def prepare(query)
            not_implemented
        end
                    
        ##
        # Checks query conditionally. It's called after first token
        # of the query.
        #
        # @since 0.9.2
        #
        
        public
        def check_conditionally(query, sym, *args, &block)
        end

     end
end

