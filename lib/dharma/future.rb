module Dharma
  class Future
    def self.call(body, executor)
      promise = Dharma.promise

      work = proc do
        begin
          promise.success(body.call)
        rescue => e
          promise.failure(e)
        end
      end

      executor.execute(work)

      promise
    end
  end
end