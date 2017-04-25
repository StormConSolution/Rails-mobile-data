class IosReclassificationService
  class << self
    def reclassify_all
      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      batch.jobs do
        IosReclassificationQueueWorker.perform_async
      end
    end

    def reclassify_ios_apps(ios_app_ids)
      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      batch.jobs do
        IpaSnapshot.select(:id).where(
          ios_app_id: ios_app_ids,
          success: true,
          scan_status: IpaSnapshot.scan_statuses[:scanned]
        ).each do |ipa_snapshot|
          IosReclassificationServiceWorker.perform_async(ipa_snapshot.id)
        end
      end
    end

    def reclassify_classdump_ids(classdump_ids)
      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      snapshot_ids = IpaSnapshot
        .joins(:class_dumps)
        .where('class_dumps.id in (?)', classdump_ids)
        .where(success: true, scan_status: IpaSnapshot.scan_statuses[:scanned])
        .pluck(:id)

      batch.jobs do
        snapshot_ids.each do |id|
          IosReclassificationServiceWorker.perform_async(id)
        end
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished iOS reclassification')
  end
end
