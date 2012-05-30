# encoding: utf-8

module FluentQuery

     ##
     # Represents data hash.
     #
     # In fact, it's common Hash class extended by method which allow
     # access its fields by "object way".
     #
     
     class Data
     
        ##
        # Contained data hash.
        #
        
        @data
     
        ## 
        # Constructor.
        #
        
        def initialize(data)
            @data = data
        end
     
        ##
        # Maps missing calls to data elements.
        #
        
        def method_missing(name, *args)
            @data[name]
        end
        
        ##
        # Maps array access to underlying data object.
        #
        
        def [](key)
            @data[key.to_sym]
        end
        
        ##
        # Converts data to hash.
        #
        
        def to_hash
            @data.to_hash.dup
        end
        
     end
     
end
