require 'rest-client'
require 'cgi'

module Gofundme
  class Search
    attr_accessor :pages
    attr_accessor :results

    def initialize(query)
      @results = 0
      @pages = 0
      @query = query
      STDERR.puts "Sleeping #{Gofundme::GOOD_CITIZEN_DELAY} seconds" if Gofundme::DEBUG
      sleep Gofundme::GOOD_CITIZEN_DELAY
      url = "https://www.gofundme.com/mvc.php?route=category&term=\"#{CGI.escape(@query)}\""
      STDERR.puts "Gofundme::Search::initialize(): Fetching: #{url}" if Gofundme::DEBUG
      page = RestClient.get url
      nok = Nokogiri::HTML(page)
      nok.xpath("//h2").each do |h2|
        if h2.inner_text.strip =~ /(\d+) results found/
          @results = $1.to_i
        end
      end

      # Site does not return more results than the first 1000 projects
      if @results > 1000
        @results = 1000
      end

      @pages = (@results / 9.0).ceil.to_i
    end

    def fetch_results(page_number)
      STDERR.puts "Gofundme::Search::results(): Sleeping #{Gofundme::GOOD_CITIZEN_DELAY} seconds" if Gofundme::DEBUG
      sleep Gofundme::GOOD_CITIZEN_DELAY
      url = "https://www.gofundme.com/mvc.php?route=homepage_norma/load_more&page=#{page_number}&term=\"#{CGI.escape(@query)}\"&country=&postalCode=&locationText="
      STDERR.puts "Gofundme::Search::results(): Fetching: #{url}" if Gofundme::DEBUG
      page = RestClient.get url
      nok = Nokogiri::HTML(page)
      links = []
      nok.xpath("//div[@class='fund-item']/a").each do |a|
        links.push a.attr('href')
      end
      return links
    end
  end
end
