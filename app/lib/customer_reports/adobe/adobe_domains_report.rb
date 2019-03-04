class AdobeDomainsReport

  # This class produces the domains report for Adobe.
  # It pulls the input data and push the output data to AWS S3.

  ######################## INSTRUCTIONS ################################

  ## TO RUN IT

  # Place the input data in the S3_INPUT_BUCKET url.
  # From terminal you can use:
  # $ awslogin
  # $ aws s3 cp local_folder/file.csv  s3://mightysignal-customer-reports/adobe/input/

  # ios_sdks.csv and android_sdks are csv files with the sdk ids and names, like:
  # 64, AliPaySDK
  # 46, Mixpanel
  # 
  # Note the IDs are different for iOS and Android!!
  #
  # adobe_domains.csv is a csv file with the domains names, example:
  # fr.as24.com
  # AS24.COM

  # To generate the report, use the Rails runner from the container bash
  # $ rails runner -e production "AdobeDomainsReport.generate('domains.csv', 'ios')"

  # Upload the produced files to the S3_OUTPUT_BUCKET url (not automated yet)
  # $ aws s3 cp /tmp/adobe.ios.output.csv s3://mightysignal-customer-reports/adobe/output/

  class << self
    def output_file_ios
      @output_file_ios ||= File.open("adobe.ios.domains.csv", "w+")
    end

    def output_file_android
      @output_file_android ||= File.open("adobe.android.domains.csv", "w+")
    end

    def apps_hot_store
      @apps_hot_store ||= AppHotStore.new
    end

    def publisher_hot_store
      @publisher_hot_store ||= PublisherHotStore.new
    end

    def domain_link
      @domain_link ||= DomainLinker.new
    end

    def sdks_to_track
      @sdks_to_track ||= []
    end
    
    def app_ids
      @app_ids ||= []
    end

    private :output_file_ios, :output_file_android, :publisher_hot_store
    
    def get_publisher_ids(domains_file_name, platform)
      domains = CSV.read(domains_file_name).flatten
      domain_data = DomainDatum.pluck(:domain)
      intersect = domains & domain_data
      intersect_website_ids = intersect.map{ |d| DomainDatum.find_by_domain(d).website_ids }.flatten.uniq
      if platform == 'ios'
        publisher_ids = intersect_website_ids.map{ |id| Website.find(id).ios_developer_ids }.flatten.uniq
      else
        publisher_ids = intersect_website_ids.map{ |id| Website.find(id).android_developer_ids }.flatten.uniq
      end
      publisher_ids
    end

    def generate(domains_file_name, platform)
      sdks_data = platform == 'ios' ? CSV.read("ios_sdks.csv") : CSV.read("android_sdks.csv")
      get_sdk_list(sdks_data)
      publisher_ids = get_publisher_ids(domains_file_name, platform)
      
      i = 0
      CSV.open("output_file_#{platform}.csv", "w") do |csv|  
        csv << headers_row()  
        publisher_ids.each do |publisher_id|
          i += 1
          p "Running #{i}"
          publisher = platform == 'ios' ? IosDeveloper.find(publisher_id) : AndroidDeveloper.find(publisher_id)
          p "Apps found #{publisher.apps.length}"
          publisher.apps.each do |app_data|
            app = apps_hot_store.read(platform, app_data.id)
            next if (app.nil? || app.empty? || app['all_version_ratings_count'].to_i < 10000 || app_ids.include?(app_data.id.to_i)) 
            app_ids << app_data.id.to_i
            skds_used = get_used_sdks(app)
            csv << produce_csv_line(publisher, app, skds_used, platform)
          end
        end
      end  

      p "Done generating file"
    ensure
      output_file_ios.close     unless output_file_ios.nil?
      output_file_android.close unless output_file_android.nil?
    end
    
    def produce_csv_line(publisher, app, skds_used, platform)
      line = [publisher.website_ids.join("|")]
      line << app['id']
      line << app['name']
      line << app['all_version_ratings_count']
      line << app['all_version_rating']
      line << app['current_version_ratings_count']
      line << app['current_version_rating']
      line << app['price']
      if app['categories'].nil? || app['categories'].empty?
        line << ""
      else
        line << app['categories'].find { |cat| cat['type'] == 'primary' }.andand['name']
      end
      line << publisher.name
      if platform == 'ios'
        line << ( 'https://itunes.apple.com/developer/id' + app['id'].to_s )
      else
        line << ( 'https://play.google.com/store/apps/details?id=' + app['bundle_identifier'].to_s )
      end
      line << app['original_release_date']
      line << app['last_updated']
      line << ""
      line << ""
      line << app['current_version']
      if app['sdk_activity'].nil? || app['sdk_activity'].empty?
        line << ""
      else
        line << app['sdk_activity'].select{|sdk| sdk['installed']}.size
      end
      line << app['mobile_priority']
      line << app['user_base']
      line << (app['ratings_by_country'] ? app['ratings_by_country'].sum {|rt| rt['ratings_per_day_current_release']} : 0)
      if platform == 'ios'
        line << ""
      else
        line << app['downloads_min']
      end
      sdks_to_track.each do |sdks|
        line << sdks[:is_used]
      end

      line
    rescue => e
      line
    end

    def get_used_sdks(app)
      return if app['sdk_activity'].nil? || app['sdk_activity'].empty?
      sdks_to_track.each do |sdk_data|
        sdk_found = app['sdk_activity'].find{ |sdkact| sdkact['id'] == sdk_data[:id].to_i && sdkact['installed'] }.present?
        sdk_data[:is_used] = sdk_found
      end
    end

    def get_sdk_list(sdks_data)
      sdks_data.each do |row|
        hash_data = {id: row[0], name: row[1], is_used: false}
        sdks_to_track << hash_data
      end
    end

    def headers_row
      headers = [
        'Websites',
        'App Id',
        'App Name',
        'Rating Count (All Versions)',
        'Rating Avg (All Versions)',
        'Rating Count (Current Version)',
        'Rating Avg (Current Version)',
        'Price',
        'Category',
        'Developer',
        'Store Link',
        'Release Date',
        'Updated Date',
        'Company Region',
        'Company Country',
        'Version',
        'Number of SDKs',
        'Mobile Priority',
        'User Base',
        'Ratings Per Day for Current Release',
        'Downloads'
      ]
      sdks_to_track.each do |sdk|
        headers << sdk[:name]
      end

      headers
    end

  end
end
