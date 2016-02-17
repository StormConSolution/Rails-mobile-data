class Zipper
  
  class << self  

    def unzip(zip_path, delete: true)
      raise NoBlockGiven, "You need to pass a block with argument unzipped_path" unless block_given?

      basename = File.basename(zip_path, ".*")  # remove extension too
      random_hex = SecureRandom.hex
      unzipped_path = "/tmp/#{basename}_unzipped_#{random_hex}"
      `unzip #{zip_path} -d #{unzipped_path}`

      yield unzipped_path

      `rm -rf #{unzipped_path}` if delete
    end

    def zip(path, delete: true)
      raise NoBlockGiven, "You need to pass a block with argument zipped_path" unless block_given?
      raise NotADirectory unless File.directory?(path)

      basename = File.basename(path)  # remove extension too
      random_hex = SecureRandom.hex

      zipped_path = "/tmp/#{basename}_#{random_hex}.zip" 

      `cd #{path} && zip -r #{zipped_path} *`

      yield zipped_path

      `rm #{zipped_path}` if delete
    end

  end

  class NoBlockGiven < StandardError

    def initialize(message = "You need to pass a block")
      super
    end

  end

  class NotADirectory < StandardError

    def initialize(message = "Must be a directory")
      super
    end

  end


end