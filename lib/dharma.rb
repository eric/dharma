module Dharma
  VERSION = '0.9.1'

  class PromiseFailure < RuntimeError; end
  class IllegalStateException < RuntimeError; end
  class TimeoutException < RuntimeError; end
  class NoSuchElementException < RuntimeError; end

  def self.default_executor
    @default_executor ||= Dharma::ThreadExecutor.new
  end

  def self.default_executor=(executor)
    @default_executor = executor
  end

  def self.promise
    Dharma::Promise.new
  end

  def self.future(executor = default_executor, &work)
    Dharma::Future.call(work, executor)
  end

  def self.sequence(promises)
    if promises.is_a?(Array) && promises.length == 1
      return promises.first
    end

    future do
      promises.map { |p| p.result }
    end
  end

  def self.first_completed_of(promises)
    p = Dharma.promise
    promises.each do |promies|
      promise.on_complete do |value, as|
        p.try_complete(value, as)
      end
    end
    p
  end

  def self.trace_completion(tag, promise, logger = Rails.logger)
    promise.on_complete do |value, as|
      logger.info "#{tag}: #{as}: #{value.inspect}"
    end
  end

  def self.ready(promise, duration = nil)
    promise.ready(duration)
  end

  def self.result(promise, duration = nil)
    promise.result(duration)
  end
end

require 'dharma/promise'
require 'dharma/future'
require 'dharma/thread_executor'