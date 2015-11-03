module IosWorker

	def run_scan(app_identifier, purpose)

		# convert data coming from ios_device_service to classdump row information
		def result_to_cd_row(data)
			data_keys = [
				:success,
				:duration,
				:install_time,
				:install_success,
				:dump_time,
				:dump_success,
				:teardown_success,
				:teardown_time,
				:error,
				:trace,
				:error_root,
				:error_teardown,
				:error_teardown_trace,
				:teardown_retry,
				:method,
				:has_fw_folder,
				:error_code
			]

			row = data.select { |key| data_keys.include? key }

			# don't upload files in development mode
			file = if !Rails.env.development? && data[:outfile_path] && false
				File.open(data[:outfile_path])
			end

			row[:class_dump] = file

			row
		end

		# create database rows
		snapshot = IpaSnapshot.create!(ios_app_id: app_identifier)
		classdump = ClassDump.create!(ipa_snapshot_id: snapshot.id)

		# get a device
		device = reserve_device(purpose)

		# no devices available...fail out and save
		if device.nil?
			classdump[:complete] = true
			classdump[:error_code] = :devices_busy
			classdump.save

			return classdump
		end

		classdump[:ios_device_id] = device.id
		classdump.save()

		# do the actual classdump
		# after install and dump, will run the procedure block which updates the classdump table. 
		# Will be useful for polling or could add some logic to send status updates
		final_result = IosDeviceService.new(device.ip).run(app_identifier, purpose) do |incomplete_result|
				row = result_to_cd_row(incomplete_result)
				row[:complete] = false
				classdump.update row
			end

		# upload the finished results
		row = result_to_cd_row(final_result)
		row.delete(:class_dump) # the state of the file hasn't changed since update after dump (don't want to reupload file)
		row[:complete] = true
		classdump.update row
		release_device(device)

		# once we've finished uploading to s3, we can delete the file
		if final_result[:outfile_path]
			`rm -f #{final_result[:outfile_path]}` if Rails.env.production?
		end

		classdump
	end

	def reserve_device(purpose, id = nil)

		device = IosDevice.transaction do

			d = if id.nil?
				IosDevice.lock.where(in_use: false, purpose: purpose).order(:last_used).first
			else
				IosDevice.lock.find_by_id(id)
			end

			if d
				d.in_use = true
				d.last_used = DateTime.now
				d.save
			end
			d
		end

		device
	end

	def release_device(device)
		device.in_use = false
		device.save
	end

	def get_dump(app_identifier, device)
		IosDeviceService.new(device.ip).run(app_identifier)
	end

	########### Functions for local development only ###########
	def run_many(id = nil)

		device = get_device(id)

		# swift_apps = [
		#   628677149, # yahoo
		#   288429040, # linked in
		#   376812381, # getty images
		#   # 624329444, # argus - memory issues
		#   419950680, # hipmunk
		#   917418728, # slideshare (entirely Swift)
		# ]

		# other_apps = [
		#   364297166, # zinio
		#   529379082, # lyft
		# ]

		apps = [
			577232024, # Lumosity
			363590051, # Netflix
			307906541, # Fandango
			284235722, # Flixster
			376510438,
			530957474,
			364191819,
			342792525,
			918820076,
			429610587,
			545519333,
			377194688,
			342643402,
		]



		puts "Trying apps"

		results = []
		apps.each do |app_identifier|
			puts "app #{results.length}: #{app_identifier}"
			results.push(single(app_identifier))
		end

		puts "Finished"
		results
	end

	# for testing without uploading results to database
	def single(app_identifier, id=nil)

		# get a device
		device = reserve_device(id)
		return nil if device.blank?

		res = get_dump(app_identifier, device)

		release_device(device)

		res

	end



end