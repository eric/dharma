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

      on_complete do |value, as|
        case as
        when :failure
          begin
            p.complete(cb.call(value))
          rescue => e
            p.failure(e)
          end
        when :success
          p.success(value)
        end
      end

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
        when :success
          p.complete(value)
        end
      end

      p
    end

    def map(cb = nil, &block)
      cb ||= block
      p = Dharma.promise

      on_complete do |value, as|
        begin
          case as
          when :success
            p.success(cb.call(value))
          when :failure
            p.failure(value)
          end
        rescue => e
          p.failure(e)
        end
      end

      p
    end

    def flat_map(cb = nil, &block)
      cb ||= block
      p = Dharma.promise

      on_complete do |value, as|
        begin
          case as
          when :success
            cb.call(value).on_complete do |value2, as2|
              case as2
              when :success
                p.success(value2)
              when :failure
                p.failure(value2)
              end
            end
          when :failure
            p.failure(value)
          end
        rescue => e
          p.failure(e)
        end
      end

      p
    end

    def failed
      p = Dharma.promise

      on_complete do |value, as|
        case as
        when :failure
          p.success(value)
        when :success
          p.failure(NoSuchElementException.new("Future.failed not completed with an exception."))
        end
      end

      p
    end
  end
end