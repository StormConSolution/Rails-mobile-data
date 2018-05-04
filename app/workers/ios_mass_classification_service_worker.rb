class IosMassClassificationServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_classification

  def perform(ipa_snapshot_id)
    IosClassificationRunner.new(
      ipa_snapshot_id,
      { log_scan_result: true, scan_type: :mass }
    ).run
    update_permissions(ipa_snapshot_id)
  end

  def update_permissions(ipa_snapshot_id)
    app_id = IpaSnapshot.find(ipa_snapshot_id).ios_app_id
    AppPermissionsHotstoreImporter.new.import_ios(app_id)
  end
end
