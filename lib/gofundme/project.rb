module Gofundme
  class Project
    FIELDS = [:key, :category, :completed, :title, :name, :profile,
    :location, :image, :youtube, :vimeo, :images, :shares,
    :amount, :goal, :pounds, :goal_pounds, :backers, :days,
    :time, :trending, :english, :story_text, :story_html,
    :link_count, :updates_count, :created_at, :fb_shares]
    FIELDS.each { |method| eval "attr_accessor #{method.to_sym}" }

    def initialize(delay=10)
      @delay = delay
    end
  end
end
