require 'zookeeper'
require 'logger'

class ZkNode
  attr_accessor :log
  
  def initialize(host = "localhost:2181", dir = "/")
    @parent_dir = dir    
    @zk = Zookeeper.new(host)
    self.log = Logger.new(STDOUT)
    
    @zk.create({ :path => @parent_dir })
  end

  def logger
    self.log
  end

  def logger=(logger)
    self.log = logger
  end
  
  def healthy(subdir, value = nil, ephemeral = true)
    begin
      @zk.create({ :path => "#{@parent_dir}/#{subdir}", :data => value, :ephemeral => ephemeral })
      log.info "(HEALTHY) setting [#{@parent_dir}/#{subdir}] to #{value}"
    rescue
      log.error "Failed to mark healthy in zookeeper"
    end
  end

  def unhealthy(subdir)
    begin
      @zk.delete({ :path => "#{@parent_dir}/#{subdir}" })
      log.warn "(UNHEALTHY) deleting [#{@parent_dir}/#{subdir}]"
    rescue
      log.add Logger::Severity::DEBUG "failed removal attempt"
    end
  end
end

