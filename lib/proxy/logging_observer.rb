require 'rx'

class ::Proxy::LoggingObserver
  include ::Proxy::Log

  def self.instance
    @instance ||= Rx::Observer.create(
      lambda { |x| logger.info(x.to_s) }
    )
  end

end