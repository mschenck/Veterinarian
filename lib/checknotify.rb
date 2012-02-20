require 'logger'
require 'httpcheck'
require 'zknode'

class CheckNotify
  attr_accessor :log
  attr_accessor :checks
  attr_accessor :notifications
  attr_accessor :last_state
  attr_accessor :health
  
  def initialize(logger=Logger.new(STDOUT))
    self.log = logger
    self.checks = []
    self.notifications = []
    self.health = false
    self.last_state = nil
  end
  
  def new_check=(check)
    self.checks << check
  end
  
  def new_notification=(notification)
    self.notifications << notification
  end
  
  def mark_healthy(key, value)
    log.info "Service healthy for #{key} at #{value}"
    notifications.each do |notify|
      notify.healthy(key, value)
    end
  end
  
  def mark_unhealthy(key)
    log.warn "Service unhealthy for #{key}"
    notifications.each do |notify|
      notify.unhealthy(key)
    end
  end
  
  def poll_checks
    checks.each do |check|
      if not health
        self.health = check.poll
      else
        self.health = health and check.poll
      end
    end
  end
  
  def check_status(key, value)
    poll_checks
    
    if health == last_state
      return
    end
    
    if health
      mark_healthy(key, value)
    else
      mark_unhealthy(key)
    end
    
    self.last_state = health
    self.health = nil
  end

end
