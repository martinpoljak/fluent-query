# encoding: utf-8
require "fluent-query/queries/abstract"

module FluentQuery
    module Queries
    
         ##
         # Compiled query.
         #
         
         class Compiled < FluentQuery::Queries::Abstract
            
            ##
            # Holds query in compiled form.
            #
            
            @query

            ##
            # Constructor.
            #

            public
            def initialize(connection, query)
                super(connection)
                @query = query.processor.compile(@connection.driver.build_query(query, :prepare))
            end
            
            ##
            # Builds prepared query string to final form.
            #
            
            public
            def build(*args)
                @query.complete(*args)
            end
            
            ##
            # Returns all selected rows ordered according to datafield from it.
            #

            public
            def assoc(specification, *args)
                self.execute(*args).assoc(specification)
            end
            
        end
    end
end

