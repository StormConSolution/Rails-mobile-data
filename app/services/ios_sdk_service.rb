class IosSdkService

  DEFAULT_FAVICON = FaviconService.get_default_favicon

  class << self

    # for front end - getting sdks data into display type
=begin
    def get_sdk_response(ios_app_id)
      resp = {
        installed_sdks: [],
        updated: nil,
        error_code: nil
      }

      error_map = {
        paid: 0,
        taken_down: 1,
        foreign: 2,
        device_incompatible: 3,
        not_ios: 4
      }

      # return error if it violates some conditions
      app = IosApp.find(ios_app_id)

      if app.display_type != "normal"
        resp[:error_code] = error_map[app.display_type.to_sym]
        return resp
      end

      price = Rails.env.production? ? app.newest_ios_app_snapshot.price.to_i : 0

      if !price.zero?
        resp[:error_code] = error_map[:paid]
        return resp
      end

      snap = app.get_last_ipa_snapshot(scan_success: true)

      # if no successful scan's done, return no data
      if !snap.nil?

        partitions = snap.ios_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
          if sdk.present? && !sdk.flagged
            if has_os_favicon?(sdk.favicon)
              memo[:os].push(sdk)
            else
              memo[:non_os].push(sdk)
            end
          end

          memo
        end

        %i(os non_os).each do |property|
          # use sort_by because it's an expensive operation and it's more efficient than sort for this type
          partitions[property] = partitions[property].sort_by do |sdk|
            sdk.get_current_apps(count_only: true)
          end
        end
        
        resp[:installed_sdks] = partitions[:non_os] + partitions[:os]
        resp[:updated] = snap.good_as_of_date
      end

      resp
    end
=end
    def get_sdk_response(ios_app_id)
      resp = {
        installed_sdks: [],
        uninstalled_sdks: [],
        updated: nil,
        error_code: nil
      }

      error_map = {
        paid: 0,
        taken_down: 1,
        foreign: 2,
        device_incompatible: 3,
        not_ios: 4
      }

      # return error if it violates some conditions
      app = IosApp.find(ios_app_id)

      if app.display_type != "normal"
        resp[:error_code] = error_map[app.display_type.to_sym]
        return resp
      end

      price = Rails.env.production? ? app.newest_ios_app_snapshot.price.to_i : 0

      if !price.zero?
        resp[:error_code] = error_map[:paid]
        return resp
      end

      snap = app.get_last_ipa_snapshot(scan_success: true)

      if !snap.nil?
        installed_sdks = snap.ios_sdks

        # handle the installed ones
        first_snaps_with_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('min(good_as_of_date) as first_seen', 'ios_sdk_id').where(id: app.ipa_snapshots.scanned, 'ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        partioned_installed_sdks = partition_sdks(ios_sdks: installed_sdks)

        resp[:installed_sdks] = partioned_installed_sdks

        resp[:installed_sdks] = partioned_installed_sdks.map do |sdk|
          formatted = format_sdk(sdk)
          row = first_snaps_with_current_sdks.find {|row| row.ios_sdk_id == sdk.id}
          # row = nil
          formatted['first_seen'] = row ? row.first_seen : nil
          formatted
        end

        # handle the uninstalled ones
        last_snaps_without_current_sdks = IpaSnapshot.joins(:ios_sdks_ipa_snapshots).select('max(good_as_of_date) as last_seen', 'ios_sdk_id').where(id: app.ipa_snapshots.scanned).where.not('ios_sdks_ipa_snapshots.ios_sdk_id' => installed_sdks.pluck(:id)).group('ios_sdk_id')

        uninstalled_sdks = IosSdk.where(id: last_snaps_without_current_sdks.pluck(:ios_sdk_id))

        partioned_uninstalled_sdks = partition_sdks(ios_sdks: uninstalled_sdks)

        resp[:uninstalled_sdks] = partioned_uninstalled_sdks.map do |sdk|
          formatted = format_sdk(sdk)
          row = last_snaps_without_current_sdks.find {|row| row.ios_sdk_id == sdk.id}
          formatted['last_seen'] = row ? row.last_seen : nil
          formatted
        end

        resp[:updated] = snap.good_as_of_date
      end

      resp
    end

    def partition_sdks(ios_sdks:)
      partitions = ios_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
        if sdk.present? && !sdk.flagged
          if has_os_favicon?(sdk.favicon)
            memo[:os].push(sdk)
          else
            memo[:non_os].push(sdk)
          end
        end

        memo
      end

      %i(os non_os).each do |property|
        # use sort_by because it's an expensive operation and it's more efficient than sort for this type
        partitions[property] = partitions[property].sort_by do |sdk|
          sdk.get_current_apps(count_only: true)
        end
      end

      partitions[:non_os] + partitions[:os]
    end

    def format_sdk(sdk)
      {
        'id' => sdk.id,
        'name' => sdk.name,
        'website' => sdk.website,
        'favicon' => sdk.favicon || DEFAULT_FAVICON
      }
    end

    def has_os_favicon?(favicon_url)

      return nil if favicon_url.nil?

      known_os_favicons = %w(
        github
        bitbucket
        sourceforge
        alamofire
        afnetworking
      )
      favicon_url.match(/#{known_os_favicons.join('|')}/) ? true : false
    end

  end
end