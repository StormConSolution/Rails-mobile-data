class ElasticSearchWorker

  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :aviato

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def queue_ios_apps
    batch = Sidekiq::Batch.new
    batch.description = 'iOS Elasticsearch Index Updating'
    batch.on(:complete, 'ElasticSearchWorker#on_complete', 'queue_type' => 'iOS')

    notify('Starting iOS ElasticSearch index updating')

    batch.jobs do
      IosApp.find_in_batches(batch_size: 1000).with_index do |the_batch, index|
        li "App #{index*1000}"
        ids = the_batch.map{ |ios_app| ios_app.id }
        ElasticSearchWorker.perform_async(:index_ios_apps, ids)
      end
    end
  end

  def queue_android_apps
    batch = Sidekiq::Batch.new
    batch.description = 'Android Elasticsearch Index Updating'
    batch.on(:complete, 'ElasticSearchWorker#on_complete', 'queue_type' => 'Android')

    notify('Starting Android ElasticSearch index updating')

    batch.jobs do
      AndroidApp.find_in_batches(batch_size: 1000).with_index do |the_batch, index|
        li "App #{index*1000}"
        ids = the_batch.map{ |android_app| android_app.id }
        ElasticSearchWorker.perform_async(:index_android_apps, ids)
      end
    end
  end

  def index_ios_apps(app_ids)
    app_ids.each_slice(100) do |ids|
      AppsIndex::IosApp.import(ids)
    end
  end

  def index_android_apps(app_ids)
    app_ids.each_slice(100) do |ids|
      AppsIndex::AndroidApp.import(ids)
    end
  end

  def index_ios_sdks
    notify('Starting iOS SDK index updating')
    IosSdkIndex::IosSdk.import
    notify('Finished iOS SDK index updating')
  end

  def index_android_sdks
    notify('Starting Android SDK index updating')
    AndroidSdkIndex::AndroidSdk.import
    notify('Finished Android SDK index updating')
  end

  def notify(msg)
    Slackiq.message(msg, webhook_name: :main)
  end

  # helper function for updating all the indices
  def update_everything
    ElasticSearchWorker.perform_async(:index_ios_sdks)
    ElasticSearchWorker.perform_async(:index_android_sdks)
    ElasticSearchWorker.perform_async(:queue_android_apps)
    ElasticSearchWorker.perform_async(:queue_ios_apps)
  end

  def on_complete(status, options)
    queue_type = options['queue_type']
    Slackiq.notify(webhook_name: :main, status: status, title: "Completed Elasticsearch updating for queue #{queue_type}")
  end
end
