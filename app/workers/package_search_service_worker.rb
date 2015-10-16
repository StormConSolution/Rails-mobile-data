class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_scraper_queue

  def single_queue?
    false
  end

  include PackageSearchWorker
  
end