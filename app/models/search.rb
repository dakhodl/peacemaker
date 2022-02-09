class Search < ApplicationRecord
  def ads(page: 1)
    ads = Ad.includes(:peer).from_peers

    if self.hops
      ads = ads.where("hops <= ?", self.hops)
    end

    terms = self.query.split(' ')
    terms.map(&:downcase).uniq.inject(ads) do |scope, term|
      scope.where("(title || description) ILIKE ?", "%#{sanitize_sql_like term}%")
    end.order(created_at: :desc).page(page)
  end


  # from https://github.com/thredded/db_text_search/blob/411c86f7b5a6b2c2c308e00dc09fbf5e5acd9ba7/lib/db_text_search/query_building.rb#L12
  # @return [String] SQL-quoted string suitable for use in a LIKE statement, with % and _ escaped.
  def sanitize_sql_like(string, escape_character = '\\')
    pattern = Regexp.union(escape_character, '%', '_')
    string.gsub(pattern) { |x| [escape_character, x].join }
  end

  def parameters_blank?
    query.blank? && hops.blank?
  end
end
