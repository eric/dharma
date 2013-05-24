require 'monitor'
require 'dharma/promise_actions'
require 'dharma/kept_promise'

module Dharma
  class Promise
    include Dharma::PromiseActions

    def self.successful(value)
      KeptPromise.new(value, :success)
    end

    def self.failed(value)
      KeptPromise.new(value, :failure)
    end

    def initialize
      @mutex     = Monitor.new
      @condition = @mutex.new_cond
    end

    def failure?
      @mutex.synchronize do
        @as == :failure
      end
    end

    def result(at_most = nil)
      ready(at_most)

      @mutex.synchronize do
        if @as == :failure
          raise @value
        else
          return @value
        end
      end
    end

    def ready(at_most = nil)
      @mutex.synchronize do
        if @as
          return self
        else
          @condition.wait(at_most ? at_most.to_f : nil)

          if @as
            return self
          else
            raise Dharma::TimeoutException.new("Futures timed out after [#{at_most}]")
          end
        end
      end
    end

    def value
      @mutex.synchronize do
        if @as
          @value
        else
          nil
        end
      end
    end

    def completed?
      @mutex.synchronize do
        @as != nil
      end
    end

    def complete(value, as = nil)
      if try_complete(value, as)
        self
      else
        raise Dharma::IllegalStateException.new("Promise already completed.")
      end
    end

    def try_complete(value, as = nil)
      on_completed = nil

      @mutex.synchronize do
        if !@as
          resolve_and_assign(value, as)

          # Grab the value from what we stored
          value, as = @value, @as

          # Clear callbacks
          on_completed = @on_completed
          @on_completed = nil

          # Wake everyone up
          @condition.broadcast

          # We don't need the condition anymore
          @condition = nil
        else
          return false
        end
      end

      if on_completed
        on_completed.each { |cb| cb.call(value, as) }
      end

      return true
    end

    def on_complete(cb = nil, &block)
      cb ||= block
      value, as = nil

      @mutex.synchronize do
        if @as
          value, as = @value, @as
        else
          (@on_completed ||= []) << cb
          return
        end
      end

      cb.call(value, as)
      return
    end

    def resolve_and_assign(value, as = nil)
      case as
      when :failure
        case value
        when Exception
          @value, @as = value, as
        else
          @value, @as = Dharma::PromiseFailure.new(value), as
          @value.set_backtrace(caller)
        end
      when :success
        @value, @as = value, as
      else
        case value
        when LocalJumpError
          @value, @as = value.exit_value, :success
        when Exception
          @value, @as = value, :failure
        else
          @value, @as = value, :success
        end
      end
    end
  end
end