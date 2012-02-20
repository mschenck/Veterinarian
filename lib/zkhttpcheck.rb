require 'httpcheck'
require 'zknode'
require 'logger'


class ZkHttpCheck < HttpCheck
  alias_method :old_initialize, :initialize
  alias_method :old_mark_healthy, :mark_healthy
  alias_method :old_mark_unhealthy, :mark_unhealthy
  
  def initialize(config)
    @config = config
    @zk = ZkNode.new(@config['zookeepers'], @config['zookeeper_path'])
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

