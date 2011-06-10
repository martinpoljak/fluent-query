# encoding: utf-8
require "date"
require "fluent-query/query"
require "fluent-query/compilers/result"

module FluentQuery

    ##
    # Query compiler.
    #

    class Compiler

        ##
        # Contains all possible formatting directives.
        #

        FORMATTING_DIRECTIVES = [:i, :s, :l, :b, :f, :d, :t, :sql, :and, :or]

        ##
        # Indicates directive prefix.
        #

        DIRECTIVE_PREFIX = "%%"

        ##
        # Compiling cache.
        #

        private
        @__compile_cache

        ##
        # Calls hash cache.
        #

        private 
        @__calls_cache

        ##
        # Processor upon which compiler should work upon.
        #

        protected
        @_processor

        ##
        # Constructor.
        #

        public
        def initialize(processor)
            @_processor = processor
        end

        ##
        # Compiles formatting.
        #

        public
        def compile_formatting(directive)
            self.calls[directive.to_sym]
        end

        ##
        # Returns calls array.
        #
        
        public
        def calls
            if not @__calls_cache
                @__calls_cache = {
                    :i => Proc::new { |v| @_processor.quote_value(v.to_i) },
                    :s => Proc::new { |v| @_processor.quote_value(v.to_s) },
                    :b => Proc::new { |v| @_processor.quote_value(v ? true : false) },
                    :f => Proc::new { |v| @_processor.quote_value(v.to_f) },
                    
                    :l => Proc::new do |v|
                        if v.kind_of? Array
                            output = argument
                        elsif v.kind_of? Hash
                            output = argument.values
                        end

                        "(" << @_processor.process_array(v) << ")"
                    end,
            
                    :d => Proc::new do |v|
                        if v.kind_of? String
                            output = Date.parse(v)
                        elsif argument.kind_of? DateTime
                            output = Date.parse(v.to_s)
                        elsif argument.kind_of? Date
                            output = v
                        end

                        @_processor.quote_value(output)
                    end,
                        
                    :t => Proc::new do |v|
                        if v.kind_of? String
                            output = DateTime.parse(v)
                        elsif argument.kind_of? Date
                            output = DateTime.parse(v.to_s)
                        elsif argument.kind_of? DateTime
                            output = v
                        end

                        @_processor.quote_value(output)
                    end,

                    :sql => Proc::new do |v|
                        if v.kind_of? MP::Fluent::Query
                            output = v.build!
                        end
                        
                        @_processor.quote_subquery(output)
                    end,
                    
                    :and => Proc::new do |v|
                        operator = @_processor.driver.quote_operator(:and)
                        @_processor.process_hash(v, operator)
                    end,

                    :or => Proc::new do |v|
                        operator = @_processor.driver.quote_operator(:or)
                        @_processor.process_hash(v, operator)
                    end,
                }
            end
            
            return @__calls_cache
        end

        ##
        # Compiles string.
        #

        public
        def compile(string) 
            output = FluentQuery::Compilers::Result::new
            prefix = self.class::DIRECTIVE_PREFIX
            buffer = ""

            # Builds compile informations
            if not @__compile_cache
                directives = self.class::FORMATTING_DIRECTIVES.map { |s| s.to_s }
                regexp = Regexp::new("^(" << directives.join("|") << ")(?:[^\w]|$)")
                
                @__compile_cache = regexp
            else
                regexp = @__compile_cache
            end
            
       
            # Splits to by directive separated parts
            string.split(prefix).each do |part|
                match = part.match(regexp)
                
                if match
                    if not buffer.empty?
                        output << buffer
                    end
                    
                    output << self.compile_formatting(match[1])
                    buffer = part[match[1].length..-1]
                else
                    buffer << prefix << part
                end
            end
            
            output << buffer
            
            # Corrects and returns result
            output.first.replace(output.first[prefix.length..-1])   # strips out initial "%%"
            return output
            
        end                
     end
 end

