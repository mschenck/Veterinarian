require 'logger'
require 'curb'

class HttpCheck
  attr_accessor :log
  
  def initialize(logger=Logger.new(STDOUT))
    self.log = logger
  end
  
  def health_check(ip, port, uri = '/')
    begin
      check_url = "http://#{ip}:#{port}#{uri}"
      h = Curl::Easy::perform(check_url)
      log.add Logger::Severity::DEBUG, "HttpCheck health_check #{check_url} : Response code #{h.response_code}"
      if h.response_code == 200
        return true
      end      
    rescue
      log.add Logger::Severity::DEBUG, "Failed to perform health check"
    end
    false
  end
end
