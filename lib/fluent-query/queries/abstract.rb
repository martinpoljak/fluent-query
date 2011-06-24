# encoding: utf-8
require "fluent-query/queries/processor"
require "abstract"

module FluentQuery
    module Queries
    
         ##
         # Represents and abstract query.
         #
         
         class Abstract
         
            ##
            # Holds connection object.
            #
            
            @connection
            attr_reader :connection
            
            ##
            # Holds appropriate query processor.
            #
            
            @processor
            
            ##
            # Constructor.
            #

            public
            def initialize(connection)
                @connection = connection
            end
            
            ##
            # Returns processor.
            #

            public
            def processor
                if not @processor
                    driver = @connection.driver
                    @processor = FluentQuery::Queries::Processor::new(driver)
                end
                
                return @processor
            end

            ##
            # Builds prepared query string to final form.
            #
            
            public
            def build(*args)
                not_implemented
            end
            
            alias :"build!" :build
            
            ##
            # Executes query and returns result object.
            #

            public
            def execute(*args)
                @connection.execute(self.build(*args))
            end
            
            alias :"execute!" :execute                
            
            ##
            # Executes query and returns count of changed/inserted rows.
            #
            
            public
            def do(*args)
                @connection.do(self.build(*args))
            end
            
            alias :"do!" :do


            ##
            # Returns all selected rows.
            #

            public
            def all(*args)
                self.execute(*args).all
            end


            ##
            # Returns one row.
            #

            public
            def one(*args)
                self.execute(*args).one
            end

            ##
            # Returns all selected rows ordered according to datafield from it.
            #

            public
            def assoc(specification, &block)
                self.execute.assoc(specification, &block)
            end

            ##
            # Returns first value of first row.
            #

            public
            def single(*args)
                self.execute(*args).single
            end

            ##
            # Handles iterating.
            #

            public
            def each(*args)
                self.execute(*args).each do |item|
                    yield item
                end
            end

            ##
            # Maps callback to array.
            #

            public
            def map(*args, &block)
                result = [ ]
                
                self.each(*args) do |item|
                    result << block.call(item)
                end

                return result
            end

            ##
            # Returns only rows for which block is true.
            #

            public
            def find_all(*args, &block)
                result = [ ]

                self.each(*args) do |item|
                    if block.call(item) === true
                        result << block.call(item)
                    end
                end

                return result
            end
            
            alias :filter :find_all
            
         end
     end
 end

