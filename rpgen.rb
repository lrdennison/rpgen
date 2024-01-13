#! /usr/bin/env ruby

require_relative "lib/rpgen.rb"

builder = Rpgen::Builder.new
builder.stanford_cs143_grammar
builder.parser_type = :LALR

builder.build

s = builder.to_html



File.write("actions.html", s)

