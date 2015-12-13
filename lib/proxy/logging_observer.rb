require 'rx'

class ::Proxy::LoggingObserver
  include ::Proxy::Log

  def self.instance
    @instance ||= RX::Observer.create(
      lambda { |x| self.stream(x)}
    )
  end

  def self.stream(event = nil)
    @stream ||= []
    @stream << event unless event.nil?
    ::Proxy::Log.logger.info(event.message.to_s) unless event.nil?
    @stream
  end

end
