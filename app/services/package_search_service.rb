class PackageSearchService

  class << self

    def search(app_identifier, apk_snap_id)
      manifest, unpack_time = extract_manifest(app_identifier)
      name = get_name(app_identifier)
      find(manifest, name, apk_snap_id, unpack_time)

      unpack_time
    end

    def extract_manifest(app_identifier)

      print "Searching for sdks in #{app_identifier}..."
      path = "data/apk_files/" + app_identifier + ".apk"
      
      start_time = Time.now()

      apk = Android::Apk.new(path)
      manifest = apk.manifest

      print 'success'

      end_time = Time.now()
      unpack_time = (end_time - start_time).to_s
      
      # v = AndroidAppSnapshot.select(:version).where(android_app_id: android_app_id).first
      # apk_snap = ApkSnapshots.create(version: v.version, google_accounts_id: google_accounts_id, android_app_id: android_app_id, download_time: download_time, unpack_time: unpack_time)

      return manifest, unpack_time

    end

    def find(manifest, name, apk_snap_id, unpack_time)
      manifest_xml = Nokogiri::XML(manifest.to_xml)
      find = ["activity", "action", "meta-data"]
      found = []
      i = 0
      for f in find
        tags = manifest_xml.xpath("//#{f}")
        for tag in tags
          app_identifier = tag["android:name"]
          unless app_identifier.include? name
            save_package(app_identifier, find.index(f), apk_snap_id)
            i += 1
          end
        end
      end
      puts " ( time : #{unpack_time} sec, packages_found : #{i} )"
    end

    def save_package(app_identifier, tag, apk_snap_id)
      AndroidPackages.create(package_name: app_identifier.to_s, android_package_tag_id: tag.to_s, apk_snapshot_id: apk_snap_id.to_s)
    end

    def get_name(app_identifier)
      app_identifier.split('.')[1]
    end

  end

end
