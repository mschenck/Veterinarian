require 'logger'
require 'curb'

class HttpCheck
  attr_accessor :log
  attr_accessor :ip
  attr_accessor :port
  attr_accessor :uri
  attr_accessor :hostname
  attr_accessor :check_url
  
  def initialize(ip, port, uri, hostname, logger=Logger.new(STDOUT))
    self.log = logger
    self.ip = ip
    self.port = port
    self.uri = uri
    self.hostname = hostname
    self.check_url = "http://#{ip}:#{port}#{uri}"
  end
  
  def poll
    begin
      check_request = Curl::Easy::perform(check_url)
      # check_request.headers['Host'] = hostname
      # check_request.perform
      
      log.add Logger::Severity::DEBUG, "HttpCheck poll: #{check_url} Response code #{check_request.response_code}"
      if check_request.response_code == 200
        return true
      end      
    rescue
      log.add Logger::Severity::DEBUG, "HttpCheck poll: Failed to perform health check"
    end
    false
  end
  
end
