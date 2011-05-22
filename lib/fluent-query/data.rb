# encoding: utf-8
require "hash-utils/string"
require "hashie/mash"

module FluentQuery

     ##
     # Represents data hash.
     #
     # In fact, it's common Hash class extended by method which allow
     # access its fields by "object way".
     #
     
     class Data < ::Hashie::Mash
=begin
        def method_missing(sym, *args, &block)
            symbol = sym.to_s
            
            if symbol.last == ?=
                  self[symbol[0..-2]] = args.first
            else
                self[symbol]
            end
        end
=end
     end
     
end
