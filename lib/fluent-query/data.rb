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
     end
     
end
