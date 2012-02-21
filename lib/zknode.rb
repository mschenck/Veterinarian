require 'rubygems'
require 'logger'
require 'zookeeper'

class ZkNode
  attr_accessor :log
  attr_accessor :connect_string
  attr_accessor :parent_dir
  attr_accessor :client
  
  def initialize(connect_string="localhost:2181", parent_dir="/", logger=Logger.new(STDOUT))
    self.log = logger
    self.connect_string = connect_string
    self.parent_dir = parent_dir  
  
    connect
    create_path
  end
  
  def connect
    # Retry connection upon failure (either can't connect or connection lost)
    self.client = nil
    while not self.client
      begin
        log.info "Connecting to zookeeper ensemble [#{connect_string}]"
        self.client = Zookeeper.new(connect_string, 1)
        return
      rescue ZookeeperExceptions::ZookeeperException::ConnectionClosed
        self.client = nil
        log.error "Zookeeper connection failure"
        sleep 1
      end
    end
  end
  
  def create_path
    begin
      client.create({ :path => parent_dir })
    rescue ZookeeperExceptions::ZookeeperException::ConnectionClosed
      log.error "Failed to create path [#{parent_dir}]"
      connect
      create_path
    end
  end
  
  def healthy(subdir, value = nil, ephemeral = true)
    begin
      log.info "(HEALTHY) setting [#{parent_dir}/#{subdir}] to #{value}"
      client.create({ :path => "#{parent_dir}/#{subdir}", :data => value, :ephemeral => ephemeral })
    rescue ZookeeperExceptions::ZookeeperException::ConnectionClosed
      log.error "Failed to mark healthy in zookeeper"
      connect
      healthy(subdir, value, ephemeral)
    end
  end

  def unhealthy(subdir)
    begin
      log.warn "(UNHEALTHY) deleting [#{parent_dir}/#{subdir}]"
      client.delete({ :path => "#{parent_dir}/#{subdir}" })
    rescue ZookeeperExceptions::ZookeeperException::ConnectionClosed
      log.add Logger::Severity::DEBUG, "failed removal attempt"
      connect
      unhealthy(subdir)
    end
  end
  
end
