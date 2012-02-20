require 'curb'
require 'logger'

class HttpCheck
  def initialize()
  end
  
  def health_check(ip, port, uri = '/')
    begin
      h = Curl::Easy::perform("http://#{ip}:#{port}#{uri}")
      puts "Received response code #{h.response_code}"
      if h.response_code == 200
        return true
      end
    rescue
      puts "Failed to perform health check"
    end
    false
  end

  def mark_healthy
    puts "Service healthy"
  end

  def mark_unhealthy
    puts "Service unhealthy"
  end
  
  def run_server(ip='127.0.0.1', port='80', check_uri='/', check_interval=5)
    last_state = nil
    while true
      # perform health check
      healthy = health_check(ip, port, check_uri)
  
      # check health, only toggle on state change
      if healthy and not last_state
        mark_healthy
      elsif not healthy and last_state
        mark_unhealthy
      end
  
      # update state and sleep
      last_state = healthy
      sleep check_interval
    end
  end
end

