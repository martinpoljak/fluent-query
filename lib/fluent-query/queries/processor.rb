# encoding: utf-8
require "date"
require "hash-utils/string"

require "fluent-query/query"
require "fluent-query/compiler"

module FluentQuery
    module Queries
    
         ##
         # Query processor.
         #
         # Its primary aim is to dive processing methods from query object as is.
         # In fact, defines something as processing session.
         #
         
         class Processor
         
            ##
            # Indicates column replacement to perform.
            # (Flag.)
            #
            
            COLUMN_REPLACEMENT = 2
            
            ##
            # Indicates string replacement to perform.
            # (Flag.)
            #
            
            STRING_REPLACEMENT = 1
            
            ##
            # Indicates formatting directive replacements to perform.
            # (Flag.)
            #
            
            FORMATTING_REPLACEMENT = 4

            ##
            # Describes formatting directive.
            # @var Regexp
            #

            FORMATTING_DIRECTIVE = /%%(?:[islbfdt]|sql|and|or)(?:[^\w]|$)/

            ##
            # Describes column directive.
            # @var Regexp
            #

            COLUMN_DIRECTIVE = /(?:^|\.|[^\'"\w\\])?\[(?:[\w\.]*[^\\\W])\](?:[^\'"\w]|\.|$)/  # problem is, it interpretes regex
                                                                                        # from left to right, so if second
                                                                                        # occurence is immedieately
                                                                                        # it will not be matched -- that
                                                                                        # is reason for ? in the begin section

            ##
            # Describes string directive.
            # @var Regexp
            #

            STRING_DIRECTIVE = /(?:^|[^\\])"/

            ##
            # Holds simple column definition.
            # @var Regexp
            #

            FORMATTING_DIRECTIVE_SIMPLE = /%%\w+/

            ##
            # Holds simple column definition.
            #

            COLUMN_DIRECTIVE_SIMPLE = /\[.+\]/

            ##
            # Final regexp for incremental fluent expanding.
            #  (internal cache)

            @__fluent_expander

            ##
            # Final regexp for incremental fluent replacing.
            #  (internal cache)

            @__fluent_replacer
            
            ##
            # Driver upon which processor should work upon.
            #

            @driver
            attr_reader :driver
            
            ##
            # Compiler associated to this processor.
            #
            
            @_compiler
            
            ##
            # Constructs processor.
            # @param MP_Fluent_Driver driver  Driver upon which processor should work upon.
            #

            public
            def initialize(driver)
                @driver = driver
            end

            ##
            # Process array to some reasonable string form.
            #
            # Joins its elements and separates them by commas. Quotes strings
            # by by-driver-defined string quoting and integers by integer quoting.
            #

            public
            def process_array(array, glue = ",")
                result = [ ]
                
                array.each do |item|
                    result << self.quote_value(item)
                end

                return result.join(glue + " ")
            end

            ##
            # Process hash to some reasonable string form.
            #
            # Joins its elements to name = value form and separates them
            # by commas. Quotes string value by by-driver-defined string quoting
            # and integers by integer quoting. Quotes name by identifiers quoting.
            #
            # Handles two modes:
            #   * "assigning" which classicaly keeps for example the '=' operator,
            #   * "comparing" which sets for example 'IS' operator for booleans.
            #

            public
            def process_hash(hash, glue = ",", equality = :comparing)
                result = [ ]
                mode = equality
                
                hash.each_pair do |key, value|
                    operator = @driver.quote_equality(value, mode)                        
                    key = self.quote_identifier(key)
                    value = self.quote_value(value)

                    result << (key + " " + operator + " " + value)
                end

                return result.join(" " << glue << " ")
            end

            ##
            # Quotes string by driver string quoting and integers by integer
            # quoting. Other values are converted to string too and
            # leaved unquoted.
            #

            public
            def quote_value(value)

                if (value.kind_of? String) or (value.kind_of? Symbol)
                    result = @driver.quote_string(value.to_s)
                elsif value.kind_of? Integer
                    result = @driver.quote_integer(value)
                elsif value.kind_of? Array
                    result = "(" << self.process_array(value) << ")"    # TODO: question is, if we should do it here, if it's enough general just for processor
                elsif value.kind_of? Float
                    result = @driver.quote_float(value)
                elsif (value.kind_of? TrueClass) or (value.kind_of? FalseClass)
                    result = @driver.quote_boolean(value)
                elsif (value.kind_of? Date) or (value.kind_of? DateTime)
                    result = @driver.quote_date_time(value)
                elsif value.kind_of? NilClass
                    result = @driver.null
                else
                    result = value.to_s
                end
                
                return result
                
            end

            ##
            # Quotes subquery by driver subquery quoting.
            #

            public
            def quote_subquery(subquery)
                if subquery.kind_of? FluentQuery::Query
                    subquery = subquery.build!
                end
                
                return @driver.quote_subquery(subquery)
            end
         
            ##
            # Quotes identifiers by identifier quoting.
            #

            public
            def quote_identifier(identifier)
                @driver.quote_identifier(identifier.to_s)
            end

            ##
            # Quotes identifiers list.
            #

            public
            def quote_identifiers(identifiers)
                identifiers.map { |item| self.quote_identifier(item) }
            end
           
            ##
            # Processes identifier list to the string representation.
            # Quotes them and joins them separated by commas.
            #

            public
            def process_identifiers(identifiers)
                self.quote_identifiers(identifiers).join(", ")
            end

            ##
            # Processed strings with format definitions and data specifications.
            #
            # Mode can be :compile, :build or :finish. Compiling means building the 
            # query without expanding the formatting directives. Finishing means
            # building the prepared query.
            #

            public
            def process_formatted(sequence, mode = :build)
            
                count = sequence.length
                i = 0
                output = ""
                                            
                replacer_settings = self.class::COLUMN_REPLACEMENT | self.class::STRING_REPLACEMENT
                expander_settings = self.class::FORMATTING_REPLACEMENT
                
                while i < count 
                    item = sequence[i]
                     
                    ##
                    
                    if item.kind_of? String
                        item = item.dup
                    
                        # Calls to each occurence of directive matching to directive
                        #  finding expression directive processing. In each call increases
                        #  sequence position counter so moves forward.

                        if mode != :finish
                            item.gsub!(self.replacer) do |directive| 
                                directive.strip!
                                self.process_directive(directive, nil, replacer_settings)
                            end
                        end
                        
                        if mode != :compile
                            item.gsub!(self.expander) do |directive| 
                                self.process_directive(directive, sequence[i += 1], expander_settings) 
                            end
                        end
                        
                        output << item

                    elsif item.kind_of? Symbol
                        output << self.quote_identifier(item)
                        
                    else
                        output << item.to_s
                        
                    end

                    output << " "
                    i += 1
                end

                return output
                
            end

            ##
            # Processes fluent directive.
            # Replacements is three bytes flag array.
            #

            public
            def process_directive(directive, argument = nil, replacements = 7)
                if (replacements & self.class::COLUMN_REPLACEMENT > 0) and (directive[0].ord == 91)           # "[", Column directive
                    result = directive.gsub(self.class::COLUMN_DIRECTIVE_SIMPLE) { |value| self.quote_identifier(value[1..-2]) }
                elsif (replacements & self.class::STRING_REPLACEMENT > 0) and (directive[-1].ord == 34)           # "\"", String directive
                    result = directive.gsub('"', @driver.quote_string("").last)
                elsif (replacements & self.class::FORMATTING_REPLACEMENT > 0) and (directive[0..1].to_sym == :"%%")   # Formatting directive
                    result = directive.gsub(self.class::FORMATTING_DIRECTIVE_SIMPLE) { |value| self.process_formatting(value[2..-1], argument) }
                else
                    result = directive
                end

                return result
            end

            ##
            # Processes formatting directive.
            #

            public
            def process_formatting(directive, argument)
                proc = self.compiler.compile_formatting(directive)
                
                if proc
                    output = proc.call(argument)
                else
                    output = ""
                end
                
                return output
            end
            
            ##
            # Returns NULL representation.
            #

            public
            def null
                @driver.null
            end

            ##
            # Returns final fluent expander query.
            #

            public
            def expander
                if @__fluent_expander.nil?
                    @__fluent_expander = self.class::FORMATTING_DIRECTIVE            
                end

                @__fluent_expander
            end

            ##
            # Returns final fluent formatter query.
            #

            public
            def replacer
                if @__fluent_replacer.nil?
                    parts = Array[self.class::COLUMN_DIRECTIVE, self.class::STRING_DIRECTIVE]

                    result = ""
                    result << "(?:(?:" << parts.join(")|(?:") << "))"
                    
                    @__fluent_replacer = Regexp::new(result)
                end

                @__fluent_replacer
            end
            
            ##
            # Returns compiler.
            #
            
            def compiler
                if @_compiler.nil?
                    @_compiler = FluentQuery::Compiler::new(self)
                end
                
                @_compiler
            end
            
            ##
            # Compiles the string.
            #
            
            def compile(string)
                self.compiler.compile(string)
            end
            
         end
     end
 end

