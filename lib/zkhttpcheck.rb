require 'httpcheck'
require 'zknode'
require 'logger'


class ZkHttpCheck < HttpCheck
  attr_accessor :log
  
  alias_method :old_initialize, :initialize
  alias_method :old_mark_healthy, :mark_healthy
  alias_method :old_mark_unhealthy, :mark_unhealthy
  
  def initialize(config)
    @config = config
    
    if @config.key? 'log_file'
      self.log = Logger.new(@config['log_file'])
    else
      self.log = Logger.new(STDOUT)
    end
    
    @zk = ZkNode.new(@config['server'], @config['zookeeper_path'])
    @zk.logger=self.log
    
    old_initialize
  end
  
  def mark_healthy
    @zk.healthy(@config['ip'], @config['hostname'])
    old_mark_healthy
  end
  
  def mark_unhealthy
    @zk.unhealthy(@config['ip'])
    old_mark_unhealthy
  end
end

