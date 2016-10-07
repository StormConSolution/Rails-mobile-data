class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk_live_scan
  # sidekiq_options backtrace: true, retry: false, queue: :sdk   # use this to test on scrapers

  RETRIES = 2

  include ApkWorker

  def initialize
    @retry = 0
  end

  def classify_if_necessary(apk_ss_id)
    if Rails.env.production?
      PackageSearchServiceSingleWorker.perform_async(apk_ss_id)
    else
      # PackageSearchServiceSingleWorker.new.perform(apk_ss_id)
      puts "Not classifying right now. Done with APK download and upload though."
    end
  end

  def scrape_type
    :live
  end

  def retries
    RETRIES
  end

  def update_live_scan_status_code?
    true
  end

  class << self
    def test(id = 1)
      new.perform(1, nil, id)
    end
  end

end
