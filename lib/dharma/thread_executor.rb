module Dharma
  class ThreadExecutor
    def initialize
    end

    def execute(work)
      Thread.new(work) do |work|
        begin
          work.call
        rescue Exception => e
          report_failure(e)
        end
      end
    end

    def report_failure(exception)
      puts "Dharma: ThreadExecutor failure: #{exception.message} (#{exception.class})\n\t#{exception.backtrace.join("\n\t")}"
    end
  end
end