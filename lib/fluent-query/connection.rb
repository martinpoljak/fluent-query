# encoding: utf-8
require "fluent-query/result"
require "fluent-query/driver"
require "fluent-query/exception"

module FluentQuery
        
     ##
     # Represents query target connection.
     #
     
     class Connection

        ##
        # Driver instance associated to the connection object.
        #
        
        @_driver

        ##
        # Holds driver class information.
        #

        @_driver_class
        
        ##
        # Connection settings.
        #

        @_settings

        ##
        # Indicates, connection is open.
        #

        @_open

        ##
        # Indicates debug mode.
        #

        @_debug

        ##
        # Initializes the connection.
        #
        # Be warn, initializer call opening the connection immediately on
        # the driver, but if driver is lazy, it will open the connection
        # at the moment in which it will want to do it.
        #

        public
        def initialize(driver_class, settings = nil, open = true)

            # Analyses

            driver = driver_class::new(self)

            if not driver.kind_of? FluentQuery::Driver
                raise FluentQuery::Exception::new("Driver must be subclass of the 'FluentQuery::Driver' class.")
            end

            # Assigns

            @_driver_class = driver_class
            @_settings = settings
            @_open = false
            @_debug = false

            # Opens if required

            if open
                @_driver = driver
                self.open!
            end
           
        end

        ##
        # Catches missing methods calls.
        #
        # Asks the driver if method call is relevant for it, of it is,
        # performs it on it.
        #

        public
        def method_missing(sym, *args, &block)
            
            # Checks if connection is in open state
            if not @_open
                raise FluentQuery::Exception::new("Connection is closed.")
            end

            ##
            
            driver = self.driver
            
            if driver.relevant_method? sym
                return __query_call(sym, *args, &block)
            else
                raise FluentQuery::Exception::new("Method '" << sym.to_s << "' isn't implemented by associated FluentQuery::Driver or FluentQuery::Connection object.")
            end
        end

        ##
        # Sets debug mode.
        #
        # Currently two are supported:
        #  * false, which turn debugging of
        #  * :dump_all which puts all queries to the output
        #

        public
        def set_debug(mode)
            @_debug = mode
        end

        ##
        # Generates query object from free query string.
        #
        # But this free query string still will be treated as string only
        # in the final query.
        #

        public
        def query(*args, &block)
            query = self._new_query_object
            
            # Calls given block in query context.
            if block
                result = query.instance_eval(&block)
            else
                result = query
            end
            
            return query
        end

        ##
        # Returns the driver object.
        #

        public
        def driver
        
            # Checks if connection is in open state
            if @_driver.nil?
                @_driver = @_driver_class::new(self)
            end
            
            return @_driver
        end

        ##
        # Opens the connection.
        #

        public
        def open!(settings = nil)

            if @_open
                raise FluentQuery::Exception::new("Connection is already open.")
            end

            ##

            if (settings == nil) and @_settings
                settings = @_settings
            elsif settings == nil
                raise FluentQuery::Exception::new("Connection settings hasn't been set or given to the #open method.")
            end
            
            self.driver.open_connection(settings)

            ##

            @_open = true
            
        end

        ##
        # Closes the connection.
        #

        public
        def close!
            if @_driver
                self.driver.close_connection!
                @_driver = nil
            end
            
            @_open = false
        end

        ##
        # Executes query.
        #

        public
        def execute(query)

            # Checks if connection is in open state
            if not @_open
                raise FluentQuery::Exception::new("Connection is closed.")
            end

            # If query is fluent query object, executes it
            if query.kind_of? FluentQuery::Query
                result = query.execute!
            else
                if @_debug == :dump_all
                    puts query
                end
                
                result = self.driver.execute(query)
            end

            # Wraps driver result to result class
            result = FluentQuery::Result::new(result)

            return result
            
        end

        ##
        # Executes query and returns count of changed/inserted rows.
        #

        public
        def do(query)

            # Checks if connection is in open state
            if not @_open
                raise FluentQuery::Exception::new("Connection is closed.")
            end

            # If query is fluent query object, executes it
            if query.kind_of? FluentQuery::Query
                result = query.do!
            else
                if @_debug == :dump_all
                    puts query
                end
                    
                result = self.driver.do(query)
            end

            return result
            
        end

        ##
        # Do in transaction context.
        #

        public
        def transaction(&block)
            self.begin
            block.call
            self.commit
        end



        #####

        ##
        # Handles built-in shortcut.
        #

        private
        def __handle_shortcut(sym, *args, &block)
            result = __query_call(sym, *args, &block)
            
            if (not args) or (args.length <= 0)
                result = result.execute!
            end

            return result
        end

        ##
        # Performs query initiating call.
        #

        private
        def __query_call(sym, *args, &block)
            query = self._new_query_object

            # Executes query conditionally. If query isn't suitable for
            # executing, sends the symbol to it and returns call result.

            query.send(sym, *args)
            
            # Calls given block in query context.
            
            if block
                result = query.instance_eval(&block)
            else
                result = query
            end
            
            return result
        end
        
        ##
        # Returns new query object.
        #
        
        protected
        def _new_query_object
            self.driver.query_class::new(self)
        end
    end         
end

