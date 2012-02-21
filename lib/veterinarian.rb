$:.unshift File.join File.dirname(__FILE__), 'veterinarian'
require 'rubygems'
require 'optparse'
require 'yaml'
require 'logger'
require 'check_notify'

class Veterinarian
  attr_accessor :log, :config, :check_notify, :key, :value
  
  def initialize
    # Parse config
    self.config = get_config
    
    self.key = config['ip']
    self.value = config['hostname']
    
    # Setup logger
    set_logger
    
    # Initialize CheckNotify
    self.check_notify = CheckNotify.new(logger=log)
    
    # Load check modules
    load_check_modules(config['checks'])
    
    # Load notification modules
    load_notify_modules(config['notifications'])
  end
  
  def load_check_modules(checks)
    checks.keys.each do |check|
      begin
        require check
        params = checks[check]
        self.new_check=Kernel.const_get(check).new(
            ip=config['ip'], 
            hostname=config['hostname'], 
            logger=log,
            params)
        log.info "Loaded check module [#{check}] successfully"
      rescue
        log.error "Failed to load check module [#{check}]"
      end
    end
  end
  
  def load_notify_modules(notificaitons)
    notificaitons.keys.each do |notify|
      begin
        require notify
        params = notificaitons[notify]
        self.new_notify=Kernel.const_get(notify).new( 
            logger=log,
            params)
        log.info "Loaded notification module [#{notify}] successfully"
      rescue
        log.error "Failed to load notification module [#{check}]"
      end
    end
  end
  
  def get_config
    options = {}
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: #{ARGV[0]} [options]"
      opts.on("-c", "--config [file]", "path to config (required)") do |c|
        options[:config_file] = c
      end
    end
    optparse.parse!
    if not options[:config_file]
      puts optparse
      exit
    end

    YAML.load_file(options[:config_file])
  end
  
  def set_logger
    self.log = Logger.new(config['logging']['file'])
    case config['logging']['level']
    when "DEBUG", "debug"
      self.log.level = Logger::DEBUG
    when "WARN", "warn"
      self.log.level = Logger::WARN
    else
      self.log.level = Logger::INFO
    end
  end
  
  def new_check=(check)
    check_notify.new_check=check
  end
  
  def new_notify=(check)
    check_notify.new_notification=check
  end
  
  def start
    while true
      check_notify.check_status(key, value)
      sleep config['CHECK_INTERVAL']
    end
  end
end