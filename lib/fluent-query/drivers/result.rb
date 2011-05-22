# encoding: utf-8
require "abstract"

module FluentQuery
    module Drivers
    
         ##
         # Represents general driver result accessor.
         #
         
         class Result
             
            ##
            # Initializes result.
            # 

            public
            def initialize
                if self.instance_of? FluentQuery::Drivers::Result
                    not_implemented
                end
            end

            ##
            # Returns all selected rows.
            #

            public
            def all
                not_implemented
            end

            ##
            # Returns one row.
            #

            public
            def one
                not_implemented
            end
            
            ##
            # Returns first value of first row.
            #

            public
            def single
                not_implemented
            end

            ##
            # Returns row as hash.
            #

            public
            def hash
                not_implemented
            end

            ##
            # Handles iterating.
            #

            public
            def each
                not_implemented
            end


            ##
            # Repeats the query leaded to the result.
            #

            public
            def repeat!
                not_implemented
            end

            ##
            # Returns rows count.
            #

            public
            def count
                not_implemented
            end

            ##
            # Frees result resources.
            #

            public
            def free!
                not_implemented
            end
         end             
    end
end
