class ProxyControl
  def start_proxies
    activate_proxies(activate: true)
  end

  def stop_proxies
    toggle_proxies(activate: false)
  end

  # should be thread-safe. needs more testing
  def toggle_proxies(activate:)
    changed = false
    signal = ProxySignal.transaction do
      row = ProxySignal.last
      if row.activated != activate
        changed = true
        row = ProxySignal.create!(activated: activate)
      end
      row
    end

    return signal unless changed
    activate ? activation_routine(signal) : deactivation_routine(signal)
    signal
  end

  def deactivation_routine(signal)
    MightyAws::InstanceControl.stop_temporary_proxies
  end

  def activation_routine(signal)
    MightyAws::InstanceControl.start_temporary_proxies
    sleep 10 # let proxies spin up and start running
    MightyAws::Api.new.register_temp_proxies_with_proxy_lbs
    sleep 35 # register unregistered proxies. Health check is every 30 seconds
  end

end
