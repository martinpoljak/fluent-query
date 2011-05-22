# encoding: utf-8
require "abstract"

module FluentQuery
        
     ##
     # Represents abstract query driver.
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
        #

        public
        def relevant_method?(name)
            not_implemented
        end


        ##
        # Indicates token is known.
        #

        public
        def known_token?(group, token_name)
            not_implemented
        end

        ##
        # Indicates, token is operator.
        #

        public
        def operator_token?(token_name)
            not_implemented
        end

        ##
        # Returns operator string according to operator symbol.
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

        public
        def quote_equality(datatype, mode = :comparing)
            not_implemented
        end

        ##
        # Indicates which query subclass to use.
        #

        public
        def query_class
            not_implemented
        end

        ##
        # Builds given query.
        #

        public
        def build_query(query)
            not_implemented
        end



        ##### QUOTING

        ##
        # Quotes string.
        #

        public
        def quote_string(string)
            not_implemented
        end

        ##
        # Quoting integer.
        #

        public
        def quote_integer(integer)
            not_implemented
        end

        ##
        # Quotes float.
        #

        public
        def quote_float(float)
            not_implemented
        end

        ##
        # Quotes field by field quoting.
        #

        public
        def quote_identifier(field)
            not_implemented
        end

        ##
        # Creates system-dependent NULL.
        #

        public
        def null
            not_implemented
        end

        ##
        # Quotes system-dependent boolean value.
        #

        public
        def quote_boolean(boolean)
            not_implemented
        end

        ##
        # Quotes system-dependent date value.
        #

        public
        def quote_date_time(date)
            not_implemented
        end

        ##
        # Quotes system-dependent subquery.
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

        public
        def open_connection(settings)
            not_implemented
        end

        ##
        # Returns native connection.
        #

        public
        def native_connection
            not_implemented
        end

        ##
        # Closes the connection.
        #

        public
        def close_connection!
            not_implemented
        end

        ##
        # Executes the query.
        #

        public
        def execute(query)
            not_implemented
        end

        ##
        # Executes the query and returns count of the changed/inserted rows.
        #

        public
        def do(query)
            not_implemented
        end

     end
end

