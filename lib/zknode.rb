require 'zookeeper'
require 'logger'

class ZkNode
  def initialize(serverlist = ["localhost:2181"], dir = "/")
    @serverlist = serverlist
    @parent_dir = dir
    
    @zk = Zookeeper.new(serverlist[0])
    @zk.create({ :path => @parent_dir })
    @log = Logger.new(STDOUT)
  end
  
  def healthy(subdir, value = nil, ephemeral = true)
    begin
      @zk.create({ :path => "#{@parent_dir}/#{subdir}", :data => value, :ephemeral => ephemeral })
      puts "(HEALTHY) setting [#{@parent_dir}/#{subdir}] to #{value}"
    rescue
      puts "Failed to mark healthy in zookeeper"
    end
  end

  def unhealthy(subdir)
    begin
      @zk.delete({ :path => "#{@parent_dir}/#{subdir}" })
      puts "(UNHEALTHY) deleting [#{@parent_dir}/#{subdir}]"
    rescue
      puts "failed removal attempt"
    end
  end
end

