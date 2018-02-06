class HotStore
  
  class MissingHotStoreField < RuntimeError; end

  @@STARTUP_NODES = [
    {:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT'] }
  ]

  @@MAX_CONNECTIONS = (ENV['HOT_STORE_REDIS_MAX_CONNECTIONS'] || 1).to_i

  def initialize()
    @redis_store = RedisCluster.new(@@STARTUP_NODES, @@MAX_CONNECTIONS)
  end

private

  def to_class(platform)
    return @platform_to_class[platform]
  end

  def key(type, platform, application_id)
    "#{type}:#{platform}:#{application_id}"
  end

  def write_entry(type, platform, id, attributes, override_key: nil, async: true)
    entry_key = override_key || key(type, platform, id)

    if @fields_to_normalize
      normalized_fields = @fields_to_normalize[platform]
      normalized_fields.each do |from, to|
        if not attributes.key?(to)
          attributes[to] = attributes[from]
          attributes.delete(from)
        end
      end
    end

    raise MissingHotStoreField unless all_required_fields_exist?(attributes)

    attributes_array = []

    attributes.each do |key, value|
      if value != nil
        attributes_array << key.to_s
        if @compressed_fields.include? key.to_s
          attributes_array << ActiveSupport::Gzip.compress(value.to_json)
        else
          attributes_array << value.to_json
        end
      end
    end
    
    return if attributes_array.empty?
    
    if async
      HotStoreThreadPool.instance.post do
        HotStoreThreadPool.connection_pool.with do |connection|
          connection.hmset(entry_key, attributes_array)
          connection.sadd(@key_set, entry_key)
        end
      end
    else
      @redis_store.hmset(entry_key, attributes_array)
      @redis_store.sadd(@key_set, entry_key)
    end
  end

  def read_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)

    attributes = {}
    
    cursor = read_scanned_attributes(type, entry_key, "0", attributes)
    while cursor != "0"
      cursor = read_scanned_attributes(type, entry_key, cursor, attributes)
    end

    attributes
  end

  def delete_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)
    @redis_store.srem(@key_set, entry_key)
    @redis_store.del(entry_key)
  end

  def read_scanned_attributes(type, entry_key, entry_cursor, entry_attributes)
    cursor, attributes = @redis_store.hscan(entry_key, entry_cursor)
    attributes.each do |attribute_tuple|
      if @compressed_fields.include? attribute_tuple[0]
        entry_attributes[attribute_tuple[0]] = ActiveSupport::JSON.decode(ActiveSupport::Gzip.decompress(attribute_tuple[1]))
      else
        entry_attributes[attribute_tuple[0]] = ActiveSupport::JSON.decode(attribute_tuple[1])
      end
    end
    cursor
  end

  def all_required_fields_exist?(app_attributes)
    if @required_fields
      @required_fields.each do |field|
        return false if app_attributes[field].nil?
      end
    end
    true
  end

end
