require 'logger'

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
    self.health = nil
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
    self.health = true
    checks.each do |check|
      self.health &= check.poll
    end
  end
  
  def check_status(key, value)
    poll_checks
    log.add Logger::Severity::DEBUG, "check_status - last_state: #{last_state} - health: #{health}"
    
    if health == last_state
      return
    end
    
    if health
      mark_healthy(key, value)
    else
      mark_unhealthy(key)
    end
    
    self.last_state = health
  end

end
