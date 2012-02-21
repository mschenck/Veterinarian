# Veterinarian modules

Veterinarian supports two types of modules:
* Checks - Used to determine the healthy state of a machine/service
* Notifications - Actions policies for changes in health checks

## Checks

A check is merely a ruby class with the required method "poll", which is expected to return the boolean "true" for healthy and "false" for unhealthy.

The "initialize" method for you check must (at least) support three named variables "ip", "hostname", and "log" (to be used for your logger facility).

''
require 'logger'

class BasicCheck
  attr_accessor :log
  
  def initialize(ip, hostname, logger=Logger.new(STDOUT))
    self.log = logger
    self.ip = ip
    self.hostname = hostname
  end
end
''

(optional) You can include additional variables by configuring them as attributes in the plugin configuration section of the configuration yaml.



## Notifications



