class SidekiqBatchQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default, retry: false

  def perform(class_name, args, bid)
    batch = Sidekiq::Batch.new(bid)

    batch.jobs do
      Sidekiq::Client.push_bulk(
        'class' => class_name.constantize,
        'args' => args
      )
    end
  end
end