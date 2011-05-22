# encoding: utf-8

module FluentQuery
    module Compilers
    
         ##
         # Query compiler result. Aka compiled string.
         #
         
         class Result < ::Array
         
            ##
            # Completes the compiled string to final one.
            #
            
            def complete(*args)
                result = ""
                
                self.each do |v|
                    if v.kind_of? Proc
                        result << v.call(args.shift)
                    else
                        result << v.to_s
                    end
                end
                
                return result
            end
            
         end
     end
 end

