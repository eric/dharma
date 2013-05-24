module Dharma
  class InlineExecutor
    def self.execute(runnable)
      runnable.call
    end
  end
end