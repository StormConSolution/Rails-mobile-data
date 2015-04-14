class BusinessEntityAndroidServiceWorker
  include Sidekiq::Worker
 
  def perform(android_snapshot_ids)
    android_snapshot_ids.each do |android_snapshot_id|
      ss = AndroidAppSnapshot.find(android_snapshot_id)

      return if ss.nil?

      url = ss.seller_url

      if UrlHelper.social?(url)
        kind = :social
      else
        url = UrlHelper.url_with_http_and_domain(url)
        kind = :primary
      end

      w = Website.find_by_url(url)

      if w.nil?
        c = Company.find_by_google_play_identifier(developer_google_play_identifier)
        c = Company.create(name: I18n.transliterate(ss.seller), google_play_identifier: ss.developer_google_play_identifier) if c.nil?
        w = Website.create(url: url, company: c, kind: kind)
      elsif w.company.nil?
        w.company = Company.create(name: I18n.transliterate(ss.seller), google_play_identifier: ss.developer_google_play_identifier)
        w.save
      end

      android_app = ss.android_app

      android_app.websites << w if !android_app.websites.include?(w)
      android_app.save

    end
  end
  
end