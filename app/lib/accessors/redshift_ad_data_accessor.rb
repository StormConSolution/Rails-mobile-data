class RedshiftAdDataAccessor

  def fetch_creatives(
    app_identifiers,
    platform,
    source_ids: nil,
    first_seen_creative_date: nil,
    last_seen_creative_date: nil,
    sort_by: 'first_seen_creative_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0)

    if ![nil, 'count', 'first_seen_creative_date', 'last_seen_creative_date'].include? sort_by
      raise "Unsupported sort_by option"
    end

    if ![nil, 'desc', 'asc'].include? order_by
      raise "Unsupported order_by option"
    end

    if !sort_by.nil?
      sort_by_sql = "ORDER BY #{sort_by}"
      if !order_by.nil?
        sort_by_sql = "#{sort_by_sql} #{order_by}"
      end
    end

    limit_sql = "LIMIT #{page_size}"
    offset = page_size * page_number
    offset_sql = "OFFSET #{offset}"

    first_seen_creative_date_sql = ""
    if !first_seen_creative_date.nil?
      first_seen_creative_date_sql = RedshiftBase::sanitize_sql_statement(["AND first_seen_creative_date > ?", first_seen_creative_date])
    end
    last_seen_creative_date_sql = ""
    if !last_seen_creative_date.nil?
      last_seen_creative_date_sql = RedshiftBase::sanitize_sql_statement(["AND last_seen_creative_date > ?", last_seen_creative_date])
    end

    _sql = "
      SELECT last_seen_creative as first_seen_creative_date,
             first_seen_creative as last_seen_creative_date,
             app_identifier,
             ad_network,
             platform,
             url,
             \"count\",
             count(*) OVER() AS full_count
      FROM mobile_ad_creative_summaries
      WHERE 
        app_identifier in (?)
        AND platform = ?
        AND ad_network in (?)
        #{first_seen_creative_date_sql}
        #{last_seen_creative_date_sql}
      #{sort_by_sql}
      #{limit_sql}
      #{offset_sql}
    "
    sql = RedshiftBase::sanitize_sql_statement([_sql, app_identifiers, platform, source_ids])
    
    results = RedshiftBase.query(sql, expires: 15.minutes).fetch
    full_count = 0
    if results.count > 0
      full_count = results[0]['full_count']
    end
    results.each do |result|
      result.delete('full_count')
    end
    return results, full_count
  end


  def query(
    platforms:['ios', 'android'],
    source_ids: [],
    first_seen_ads_date: nil,
    last_seen_ads_date: nil,
    sort_by: 'first_seen_ads_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0,
    extra_fields:[])
    # Filters and sorts apps by ad intel data.
    # Params:
    #   platforms: The platforms to filter this query by.
    #   sort_by: A field to sort the result set by one of first_seen_ads_date, last_seen_ads_date or user_base_display_score.
    #   order_by: Order by asc or desc,
    #   source_ids: A list of source_ids from available_sources to which this query applies to nil => all supported.
    # Returns:
    # See AdDataAccessor

    platforms_sql = nil

    if platforms.count != AdDataPermissions::APP_PLATFORMS.count
      platforms_sql = "mobile_ad_data_summaries.platform in ('#{platforms.join("','")}')"
    end
    source_ids_sql = "mobile_ad_data_summaries.ad_network in ('#{source_ids.join("','")}')"

    where_clauses = [platforms_sql, source_ids_sql]
    if ! first_seen_ads_date.nil?
      where_clauses.append(RedshiftBase::sanitize_sql_statement(["first_seen_ads_date > ?", first_seen_ads_date]))
    end
    if ! last_seen_ads_date.nil?
      where_clauses.append(RedshiftBase::sanitize_sql_statement(["last_seen_ads_date > ?", last_seen_ads_date]))
    end

    where_sql = where_clauses.compact.join(" AND ")

    if ![nil, 'first_seen_ads_date', 'last_seen_ads_date', 'user_base_display_score'].include? sort_by
      raise "Unsupported sort_by option"
    end
    if sort_by == 'user_base_display_score'
      sort_by = 'user_base_score'
    end
    if ![nil, 'desc', 'asc'].include? order_by
      raise "Unsupported order_by option"
    end

    if !sort_by.nil?
      sort_by_sql = "ORDER BY #{sort_by}"
      if !order_by.nil?
        sort_by_sql = "#{sort_by_sql} #{order_by}"
      end
    end

    limit_sql = "LIMIT #{page_size}"
    offset = page_size * page_number
    offset_sql = "OFFSET #{offset}"
    extra_fields_sql = (extra_fields.map{|f, as_f| "#{f} as #{as_f}"} + [""]).join(",")
    sql = "
        WITH advertised_apps as (
        SELECT
            app_identifier,
            platform,
            min(mobile_ad_data_summaries.first_seen_ads_date) AS first_seen_ads_date,
            datediff(DAY,
            min(mobile_ad_data_summaries.first_seen_ads_date)::TIMESTAMP,
            GETDATE()) AS first_seen_ads_days,
            max(mobile_ad_data_summaries.last_seen_ads_date) AS last_seen_ads_date,
            datediff(DAY,
            max(mobile_ad_data_summaries.last_seen_ads_date)::TIMESTAMP,
            GETDATE()) AS last_seen_ads_days,
            listagg(DISTINCT mobile_ad_data_summaries.ad_network,
            ',') AS ad_networks,
            listagg(DISTINCT mobile_ad_data_summaries.ad_formats,
            ',') AS ad_formats
        FROM
            mobile_ad_data_summaries
            WHERE
            #{where_sql}
        GROUP BY
            app_identifier, platform
        )
        select
            #{extra_fields_sql}
            advertised_apps.app_identifier,
            advertised_apps.platform,
            advertised_apps.first_seen_ads_date,
            advertised_apps.first_seen_ads_days,
            advertised_apps.last_seen_ads_date,
            advertised_apps.last_seen_ads_days,
            advertised_apps.ad_networks,
            advertised_apps.ad_formats,
            count(*) OVER() AS full_count
        from apps, advertised_apps where apps.app_identifier = advertised_apps.app_identifier
        AND apps.platform = advertised_apps.platform
        #{sort_by_sql}
        #{limit_sql}
        #{offset_sql}
      "
    results = RedshiftBase.query(sql, expires: 15.minutes).fetch
    full_count = 0
    if results.count > 0
      full_count = results[0]['full_count']
    end
    results.each do |result|
      result.delete('full_count')
    end
    return results, full_count
  end
end
