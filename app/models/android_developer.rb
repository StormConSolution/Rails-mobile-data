class AndroidDeveloper < ActiveRecord::Base
  
  belongs_to :company
  has_many :android_apps

  has_many :android_developers_websites
  has_many :websites, through: :android_developers_websites

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :valid_android_developer_websites, -> { where(is_valid: true)}, class_name: 'AndroidDevelopersWebsite'
  has_many :valid_websites, through: :valid_android_developer_websites, source: :website

  include DeveloperContactWebsites

  def get_website_urls
    websites.pluck(:url).uniq
  end

  def get_valid_website_urls
    valid_websites.pluck(:url).uniq
  end

  def fortune_1000_rank
    valid_websites.joins(:domain_datum).pluck(:fortune_1000_rank).compact.min
  end

  def sorted_android_apps(category, order, page)
    filter_args = {
      app_filters: {'publisherId' => self.id},
      page_size: 100,
      page_num: [page.to_i, 1].max,
      sort_by: category || 'last_updated',
      order_by: order || 'desc'
    }
     
    filter_results = FilterService.filter_android_apps(filter_args)

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? AndroidApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    return results, filter_results.total_count
  end

  def headquarters(limit=100)
    headquarters = []
    valid_websites.joins(:domain_datum).uniq.limit(limit).
      pluck('domain_data.domain','street_number','street_name','sub_premise','city','postal_code','state',
            'state_code','country','country_code','lat','lng').each do |data|
      next unless data[9]
      headquarters << {
        domain: data[0],
        street_number: data[1],
        street_name: data[2],
        sub_premise: data[3],
        city: data[4],
        postal_code: data[5],
        state: data[6],
        state_code: data[7],
        country: data[8],
        country_code: data[9],
        lat: data[10],
        lng: data[11]
      }
    end
    headquarters.uniq
  end
end
