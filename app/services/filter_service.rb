class FilterService
  class << self
  
    def order_helper(apps_index, sort_by, order_by)
      if ['user_base', 'mobile_priority'].include?(sort_by)
        mapping = sort_by == 'user_base' ? IosApp.user_bases : IosApp.mobile_priorities
        apps_index.order(
                          {
                            "_script" => {
                              "script" => "doc['#{sort_by}'].empty ? -1 : factor[doc['#{sort_by}'].value]",
                              "params" => {
                                "factor" => mapping
                              },
                              "type" => "number",
                              "order" => order_by
                            }
                          }
                        )

      else
        apps_index.order(sort_by => order_by)
      end
    end

    def date_filter(filter)
      case filter["date"].to_i
      when 1
        {'gte' => 'now-7d/d'}
      when 2
        {'gte' => 'now-30d/d', 'lt' => 'now-7d/d'}
      when 3
        {'gte' => 'now-90d/d', 'lt' => 'now-30d/d'}
      when 4
       {'gte' => 'now-180d/d', 'lt' => 'now-90d/d'}
      when 5
        {'gte' => 'now-240d/d', 'lt' => 'now-180d/d'}
      when 6
        {'gte' => 'now-365d/d', 'lt' => 'now-240d/d'}
      when 7
        {'lt' => 'now-365d/d'}
      end
    end

    def filter_ios_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'ios')
    end

    def filter_android_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'android')
    end

    def filter_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc', platform: 'ios')
      apps_index = platform == 'ios' ? AppsIndex::IosApp : AppsIndex::AndroidApp

      ['sdkFiltersOr', 'sdkFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = filter_type == 'sdkFiltersOr' ? 'or' : 'and'
        sdk_query = {short_filter_type => []}
        app_filters[filter_type].each do |filter|
          date = date_filter(filter)
          case filter["status"].to_i
          when 0
            if date 
              sdk_query[short_filter_type] << {"nested" => {"path" => "installed_sdks", "filter" => {"and" => [{"terms" => {"installed_sdks.id" => [filter["id"]]}}, {"range" => {"installed_sdks.first_seen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"installed_sdks.id" => [filter["id"]]}}
            end
          when 1
            if date
              sdk_query[short_filter_type] << {"nested" => {"path" => "uninstalled_sdks", "filter" => {"and" => [{"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}, {"range" => {"uninstalled_sdks.last_seen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}
            end
          when 2
            sdk_query[short_filter_type] << {"and" => [{"not" => {"terms" => {"installed_sdks.id" => [filter["id"]]}}}, {"not" => {"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}}]}
          when 3
            sdk_query[short_filter_type] << {"not" => {"terms" => {"installed_sdks.id" => [filter["id"]]}}}
          end
        end
        apps_index = apps_index.filter(sdk_query) unless sdk_query[short_filter_type].blank?
      end

      ['locationFiltersOr', 'locationFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = filter_type == 'locationFiltersOr' ? 'or' : 'and'
        location_query = {short_filter_type => []}
        app_filters[filter_type].each do |filter|
          case filter["status"].to_i
          when 0
            if filter["state"].present? && filter['state'] != "0"
              location_query[short_filter_type] << {"nested" => {"path" => "headquarters", "filter" => {"and" => [{"terms" => {"headquarters.country_code" => [filter["id"]]}}, {"terms" => {"headquarters.state_code" => [filter["state"]]}}]}}}
            else
              location_query[short_filter_type] << {"term" => {"headquarters.country_code" => filter["id"]}}
            end
          when 1
            location_query[short_filter_type] << {"and" => [{"term" => {"app_stores.country_code" => filter["id"]}}, {"term" => {"app_stores_count" => 1}}]}
          when 2
            location_query[short_filter_type] << {"term" => {"app_stores.country_code" => filter["id"]}}
          when 3
            location_query[short_filter_type] << {"not" => {"term" => {"app_stores.country_code" => filter["id"]}}}
          end
        end
        apps_index = apps_index.filter(location_query) unless location_query[short_filter_type].blank?
      end
      
      if company_filters['fortuneRank'].present?
        apps_index = apps_index.filter({"terms" => {"fortune_rank" => eval("[*'1'..'#{company_filters['fortuneRank'].to_i}']")}})
      end

      if app_filters['adSpend'].present?
        apps_index = apps_index.filter({"terms" => {"facebook_ads" => [true]}})
      end

      if app_filters['price'].present?
        apps_index = app_filters['price'] == 'paid' ? apps_index.filter({"terms" => {"paid" => [true]}}) : apps_index.filter({"not" => {"terms" => {"paid" => [true]}}})
      end

      if app_filters['inAppPurchases'].present?
        apps_index = app_filters['inAppPurchases'] == 'true' ? apps_index.filter({"terms" => {"in_app_purchases" => [true]}}) : apps_index.filter({"not" => {"terms" => {"in_app_purchases" => [true]}}})
      end

      if app_filters['oldAdSpend'].present?
        apps_index = apps_index.filter({"terms" => {"old_facebook_ads" => [true]}})
      end

      if app_filters['publisherId'].present?
        apps_index = apps_index.filter({"term" => {"publisher_id" => app_filters['publisherId']}})
      end

      if app_filters['mobilePriority'].present?
        apps_index = apps_index.filter({"terms" => {"mobile_priority" => app_filters['mobilePriority'], "execution" => "or"}})
      end

      if app_filters['userBases'].present?
        if platform == 'ios'
          apps_index = apps_index.filter({"terms" => {"user_bases.user_base" => app_filters['userBases'], "execution" => "or"}})
        else
          apps_index = apps_index.filter({"terms" => {"user_base" => app_filters['userBases'], "execution" => "or"}})
        end
      end

      if app_filters['categories'].present?
        if platform == 'android'
          app_filters['categories'] += android_gaming_categories if app_filters['categories'].include?('Games')
          app_filters['categories'] += android_family_categories if app_filters['categories'].include?('Family')
        end
        apps_index = apps_index.filter({"terms" => {"categories" => app_filters['categories'], "execution" => "or"}})
      end

      if app_filters['downloads'] #android only

        # Download Value Ranges - broken up to intervals of scraped data
        download_min_values = [
            [1, 5, 10, 50, 100, 500, 1000, 5000, 10000],  # 0 - 50K
            [50000, 100000],                              # 50K - 500K
            [500000, 1000000, 5000000],                   # 500K - 10M
            [10000000, 50000000],                         # 10M - 100M
            [100000000, 500000000],                       # 100M - 1B
            [1000000000]                                  # 1B - 5B
        ]
        
        download_ids = app_filters['downloads'].map{|x| x['id'].to_i}

        filter_values_array = []

        download_ids.each do |id|
          filter_values_array += download_min_values[id]
        end

        apps_index = apps_index.filter({"terms" => {"downloads_min" => filter_values_array, "execution" => "or"}})
      end

      apps_index = order_helper(apps_index, sort_by, order_by)

      apps_index = apps_index.limit(page_size).offset((page_num - 1) * page_size)
    end

    def android_gaming_categories
      [
       'Action',
       'Adventure',
       'Arcade',
       'Board',
       'Card',
       'Casino',
       'Casual',
       'Educational',
       'Music',
       'Puzzle',
       'Racing',
       'Role Playing',
       'Simulation',
       'Sports',
       'Strategy',
       'Trivia',
       'Word'
      ]
    end

    def android_family_categories
      [
       'Action & Adventure',
       'Brain Games',
       'Creativity',
       'Education',
       'Music & Video',
       'Pretend Play'
      ]
    end
  end
end