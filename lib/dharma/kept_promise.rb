module Dharma
  class KeptPromise
    include Dharma::PromiseActions

    def initialize(value, as)
      @value, @as = value, as
    end

    def failure?
      @as == :failure
    end

    def result(at_most = nil)
      if @as == :failure
        raise @value
      else
        return @value
      end
    end

    def ready(at_most = nil)
      return self
    end

    def value
      @value
    end

    def completed?
      true
    end

    def on_complete(cb = nil, &block)
      cb ||= block

      cb.call(@value, @as)
      return
    end
  end
end