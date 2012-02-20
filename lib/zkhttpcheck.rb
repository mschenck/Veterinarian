require 'logger'
require 'httpcheck'
require 'zknode'

class ZkHttpCheck
  attr_accessor :log
  
  def initialize(config)
    @config = config
    
    if @config.key? 'log_file'
      self.log = Logger.new(@config['log_file'])
    else
      self.log = Logger.new(STDOUT)
    end
    
    # Initialize zookeeper client
    @zk_client = ZkNode.new(@config['zk_conn_string'], @config['zookeeper_path'], self.log)    
    @httpd_chk = HttpCheck.new(self.log)
  end
  
  def mark_healthy
    @zk_client.healthy(@config['ip'], @config['hostname'])
    log.info "Service healthy"
  end
  
  def mark_unhealthy
    @zk_client.unhealthy(@config['ip'])
    log.warn "Service unhealthy"
  end
  
  def run_check(ip='127.0.0.1', port='80', check_uri='/', check_interval=5)
    last_state = nil
    while true
      # perform health check
      healthy = @httpd_chk.health_check(ip, port, check_uri)
  
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

