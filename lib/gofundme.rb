require "gofundme/version"
require "gofundme/project"
require "gofundme/search"

Gofundme::DEBUG = false
Gofundme::EURO_EXCHANGE_RATE = 1.13
Gofundme::POUND_EXCHANGE_RATE = 1.31
Gofundme::GOOD_CITIZEN_DELAY = 10

STDERR.puts "Debug is on" if Gofundme::DEBUG

module Gofundme
end
