class SdkDll < ActiveRecord::Base

  has_many :apk_snapshots_sdk_dlls
  has_many :apk_snapshots, through: :apk_snapshots_sdk_dlls

  has_many :ipa_snapshots_sdk_dlls
  has_many :ipa_snapshots, through: :ipa_snapshots_sdk_dlls

end
