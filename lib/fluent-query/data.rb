# encoding: utf-8

module FluentQuery

     ##
     # Represents data hash.
     #
     # In fact, it's common Hash class extended by method which allow
     # access its fields by "object way".
     #
     
     class Data < ::Hash
     
        ##
        # Maps missing calls to data elements.
        #
        
        def method_missing(name)
            self[name]
        end
        
     end
     
end
