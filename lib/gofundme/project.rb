require 'nokogiri'
require 'rest-client'

module Gofundme
  class Project
    FIELDS = [:key, :category, :completed, :title, :name, :profile,
    :location, :image, :youtube, :vimeo, :images, :shares,
    :amount, :goal, :pounds, :euros, :goal_pounds, :goal_euros, :backers,
    :time, :trending, :english, :story_text, :story_html,
    :link_count, :updates_count, :created_at, :fb_shares, :updates]
    FIELDS.each { |field| eval "attr_accessor :#{field}" }

    def to_hash
      hash = {}
      FIELDS.each do |field|
        hash[field]=self.send(field)
      end
      hash[:updates] = @updates
      return hash
    end

    def initialize
      @updates = []
    end

    def self.scrape(url)
      STDERR.puts "Gofundme::Project.scrape(): Sleeping #{Gofundme::GOOD_CITIZEN_DELAY} seconds" if Gofundme::DEBUG
      sleep Gofundme::GOOD_CITIZEN_DELAY
      STDERR.puts "Gofundme::Project.scrape(): Fetching: #{url}" if Gofundme::DEBUG
      p = Gofundme::Project.new
      if url =~ /https:\/\/www.gofundme.com\/(.*)/i
        p.key = $1
      else
        raise "Malformed URL #{url}"
      end

      begin
        page = RestClient.get url
        nok = Nokogiri::HTML(page)
        p.completed = false
        p.title = ''
        p.name = ''
        nok.xpath("//h1[@class='campaign-title']").each do |h1|
          p.title = h1.inner_text.strip
        end
        if p.title == ''
          nok.xpath("//h1[@class='campaign-title pb']").each do |h1|
            p.title = h1.inner_text.strip
          end
        end
        if p.title == nil
          STDERR.puts "No title found! Exiting..." if Gofundme::DEBUG
          raise "No title found"
        end
        nok.xpath("//img[@class='campaign-img']").each do |tag|
          p.image = tag.attr('src')
        end
        nok.xpath("//iframe[@title='YouTube video player']").each do |iframe|
          p.youtube = iframe.attr('src')
        end
        nok.xpath("//iframe[@media_type='2']").each do |iframe|
          p.vimeo = iframe.attr('src')
        end
        p.images = p.image ? 1 : 0
        nok.xpath("//div[@id='js-open-media-viewer']").each do |div|
          if div.inner_text.strip =~ /(\d+)/
            p.images = $1
          end
        end
        p.shares = 0
        nok.xpath("//strong[@class='js-share-count-text']").each do |strong|
          if strong.inner_text.strip =~ /(\d+)/
            p.shares = $1.to_i
          end
        end
        p.amount = 0
        p.pounds = 0
        p.euros = 0
        p.goal = 0
        p.goal_pounds = 0
        p.goal_euros = 0
        nok.xpath("//h2[@class='goal']|//h2[@class='goal mb0']").each do |h2|
          amount = 0
          h2.xpath("./strong").each do |h2|
            amount = h2.inner_text.strip
          end

          if amount =~ /^\$(.*)/
            p.amount = $1.gsub(/,/, '').to_f
          elsif amount =~ /^£(.*)/
            p.pounds = $1.gsub(/,/, '').to_f
            p.amount = p.pounds * Gofundme::POUND_EXCHANGE_RATE
          elsif amount =~ /^€(.*)/
            p.euros = $1.gsub(/,/, '').to_f
            p.amount = p.euros * Gofundme::EURO_EXCHANGE_RATE
          end

          goal = 0
          h2.xpath("./span").each do |span|
            goal = span.inner_text.strip
          end
          if goal =~ /of \$((?:\d+|[,.])+)/
            p.goal = $1.gsub(/,/, '').to_f
          elsif goal =~ /of £((?:\d+|[,.])+)/
            p.goal_pounds = $1.gsub(/,/, '').to_f
            p.goal = p.goal_pounds * Gofundme::POUND_EXCHANGE_RATE
          elsif goal =~ /of €((?:\d+|[,.])+)/
            p.goal_euros = $1.gsub(/,/, '').to_f
            p.goal = p.goal_euros * Gofundme::EURO_EXCHANGE_RATE
          else
            # no donations yet
            if h2.attr('class') =~ /mb0/
              p.completed = true
              nok.xpath("//title").each do |title|
                if title.inner_text.strip =~ /Fundraiser by ([^:]+):/
                  p.name = $1.strip
                end
              end
            else
              p.goal = p.amount
              p.amount = nil
            end
          end
        end
        p.backers = 0
        p.time = ''
        nok.xpath("//div[@class='campaign-status text-small']").each do |div|
          if div.inner_text =~ /Campaign created /
            p.backers = 0
            if div.inner_text =~ /Campaign created (\d+ \w+)/
              p.time = $1
            end
          else
            p.backers = div.xpath("./span").first.inner_text.to_i
            if div.inner_text =~ /(?:people|person) in (\d+ \w+)/
              p.time = $1
            end
          end
        end
        p.trending = false
        nok.xpath("//div[@data-identifier='trending']").each do |div|
          p.trending = true
        end
        p.story_html = ''
        p.story_text = ''
        p.link_count = 0
        p.english = true
        nok.xpath("//div[@id='story']/div[3]").each do |div|
          p.story_html = div.inner_html.strip
          p.link_count = 0
          div.xpath(".//a").each do |a|
            p.link_count += 1
          end
          if p.story_text =~ /Translate story to English/
            p.english = false
          else
            p.story_text = div.inner_text.strip
          end
        end
        p.updates_count = 0
        # <a href="#updates" role="tab" aria-controls="updates" aria-selected="false" id="updates-label" tabindex="-1">Updates &nbsp; <span class="badge">3</span></a>
        nok.xpath("//a[@href='#updates']/span").each do |span|
          if span.inner_text =~ /(\d+)/
            p.updates_count = $1.to_i
          end
        end
        p.created_at = 0
        nok.xpath("//div[@class='created-date']").each do |div|
          p.created_at = div.inner_text.strip
        end
        p.fb_shares = ''
        nok.xpath("//strong[@class='js-share-count-text']").each do |strong|
          p.fb_shares = strong.inner_text.strip
        end

        p.profile = ''
        nok.xpath("//a[@class='js-profile-co']").each do |a|
          p.name = a.inner_text.strip
          p.profile = a.attr('href')
        end
        p.category = ''
        nok.xpath("//a[@class='icon-link category-link-name js-category-link']/span").each do |span|
          p.category = span.inner_text.strip
        end
        p.location= ''
        nok.xpath("//a[@class='icon-link location-name js-location-link']").each do |a|
          a.xpath("./i").each do |i|
            i.remove
          end
          p.location = a.inner_text.gsub(/^\W+/, '').strip
        end

        # Now parse out the updates
        i = 1
        nok.xpath("//div[@class='update-text']").each do |div|
          update_text = div.inner_text.strip
          update_html = div.inner_html.strip
          links = 0
          div.xpath(".//a").each do |a|
            links += 1
          end
          p.updates.push [i, update_text, update_html, links]
          i += 1
        end

      rescue Exception => e
        puts "Exception: #{e}: #{e.backtrace}"
        raise
      end
      return p
    end
  end
end
