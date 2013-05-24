module Dharma
  module PromiseActions
    def on_success(cb = nil, &block)
      cb ||= block

      on_complete do |value, as|
        case as
        when :success
          cb.call(value)
        end
      end
    end

    def on_failure(cb = nil, &block)
      cb ||= block

      on_complete do |value, as|
        case as
        when :failure
          cb.call(value)
        end
      end
    end

    def success(value)
      complete(value, :success)
    end

    def failure(value)
      complete(value, :failure)
    end

    def try_success(value)
      try_complete(value, :success)
    end

    def try_failure(value)
      try_complete(value, :failure)
    end

    def complete_with(other)
      other.on_complete { |value, as| complete(value, as) }
      self
    end

    def recover(cb = nil, &block)
      cb ||= block
      p = Dharma.promise

      on_complete { |value| p.complete(cb.call(value)) }

      p
    end

    def recover_with(cb = nil, &block)
      cb ||= block
      p = Dharma.promise

      on_complete do |value, as|
        case as
        when :failure
          begin
            p.complete_with(cb.call(value))
          rescue => e
            p.failure(e)
          end
        else
          p.complete(value)
        end
      end

      p
    end
  end
end