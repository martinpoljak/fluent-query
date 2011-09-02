# encoding: utf-8
require "fluent-query/queries/abstract"

module FluentQuery
    module Queries
    
         ##
         # Prepared query.
         #
         
         class Prepared < FluentQuery::Queries::Abstract
            
            ##
            # Holds query in prepared form.
            #
            
            @query

            ##
            # Constructor.
            #

            public
            def initialize(connection, query)
                super(connection)
                @query = @connection.driver.prepare(query)
            end
            
            ##
            # Builds prepared query string to final form.
            #
            
            public
            def build(*args)
                [@query, args]
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

