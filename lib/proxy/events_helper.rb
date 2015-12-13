require 'rx'

class ::Proxy::EventsObservable
  def self.instance
    @instance ||= RX::Subject.new
  end
end

class ::Proxy::Event
  attr_reader :module, :level, :message, :backtrace
  def initialize(a_module, level, message, backtrace = nil)
    @module = a_module
    @level = level
    @message = message
    @backtrace = backtrace
  end
end

module ::Proxy::EventHelpers
  def emit_event(an_event)
    ::Proxy::EventsObservable.instance.on_next(an_event)
  end

  def emit_debug(message, backtrace = nil)
    emit_event(Proxy::Event.new(:root, :debug, message, backtrace))
  end

  def emit_info(message, backtrace = nil)
    emit_event(Proxy::Event.new(:root, :info, message, backtrace))
  end

  def emit_warning(message, backtrace = nil)
    emit_event(Proxy::Event.new(:root, :warn, message, backtrace))
  end

  def emit_error(message, backtrace = nil)
    emit_event(Proxy::Event.new(:root, :error, message, backtrace))
  end
end
