class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

	enum device: [:shit_phone, :nexus_9_tablet, :moto_g_phone]
	enum scrape_type: [:full, :live]

end
