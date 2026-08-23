# frozen_string_literal: true

module Jekyll
  # Removes internal drafting artifacts from rendered content and normalizes
  # legacy date-prefixed post links to the site's current permalink format.
  class ContentHygieneGenerator < Generator
    safe true
    priority :highest

    INTERNAL_CITATION = /[ \t]*filecite[^\n]+/.freeze
    LEGACY_POST_LINK = %r{\]\(/\d{4}-\d{2}-\d{2}-([a-z0-9_-]+)\)}i.freeze

    def generate(site)
      site.posts.docs.each { |document| sanitize!(document) }
      site.pages.each { |page| sanitize!(page) }
    end

    private

    def sanitize!(document)
      return unless document.respond_to?(:content) && document.content

      document.content = document.content
                                 .gsub(INTERNAL_CITATION, "")
                                 .gsub(LEGACY_POST_LINK) { "](/blog/#{Regexp.last_match(1)}/)" }
    end
  end
end
