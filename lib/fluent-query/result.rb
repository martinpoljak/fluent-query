# encoding: utf-8
require "fluent-query/exception"

module FluentQuery
                
     ##
     # Represents result wrapper.
     #
     
     class Result

        ##
        # Holds driver result.
        #

        @_result
        
        ##
        # Initializes result.
        # 

        public
        def initialize(result)
            @_result = result
        end

        ##
        # Finishes the result set.
        # (Cleanups.)
        #

        public
        def finish!
            @_result.free!
        end

        ##
        # Returns all selected rows.
        #

        public
        def all
            @_result.all
        end

        ##
        # Returns one row.
        #

        public
        def one
            @_result.one
        end

        ##
        # Returns first value of first row.
        #

        public
        def single
            @_result.single
        end

        ##
        # Returns data in complex associative level.
        # Only two levels are currently supported.
        #

        public
        def assoc(*specification, &block)
        
            if block.nil?
                block = Proc::new { |v| v }
            end
            
            specification = specification.map { |i| i.to_s }
            length = specification.length
            result = { }

            ##
            
            if length == 0
                raise FluentQuery::Exception::new("Specification must content at least one field name.")
            elsif length == 1
                key = specification.first
                
                self.each do |item|
                    result[item[key]] = block.call(item)
                end
            else
                key_1, key_2 = specification
                
                self.each do |item|
                    target_1 = item[key_1]
                    target_2 = item[key_2]

                    if not result[target_1]
                        result[target_1] = { }
                    end
                    
                    result[target_1][target_2] = block.call(item)
                end
            end
            
            return result
        end

        ##
        # Handles iterating.
        #

        public
        def each(&block)
            @_result.each &block
            self.free!
        end

        ##
        # Repeats the query leaded to the result.
        #

        public
        def repeat!
            @_result.repeat!
        end

        ##
        # Returns rows count.
        #

        public
        def count
            @_result.count
        end
        
        ##
        # Frees result resources.
        #

        public
        def free!
            @_result.free!
        end
        
        ##
        # Finishes the result set.
        # (Cleanups.)
        #

        alias :"finish!" :"free!"
        
     end
 end
