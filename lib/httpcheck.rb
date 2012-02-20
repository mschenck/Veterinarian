require 'logger'
require 'curb'

class HttpCheck
  attr_accessor :log
  
  def initialize(logger=Logger.new(STDOUT))
    self.log = logger
  end
  
  def health_check(ip, port, uri = '/')
    begin
      h = Curl::Easy::perform("http://#{ip}:#{port}#{uri}")
      log.add Logger::Severity::DEBUG, "Received response code #{h.response_code}"
      if h.response_code == 200
        return true
      end      
    rescue
      log.add Logger::Severity::DEBUG, "Failed to perform health check"
    end
    false
  end
end
