require 'test_helper'

class PromiseTest < Test::Unit::TestCase
  def test_new_promise_is_not_completed
    promise = Dharma.promise
    
    assert !promise.completed?
  end

  def test_completed_promise_is_completed
    promise = Dharma.promise
    
    assert promise.try_complete(1)
    assert promise.completed?
  end

  def test_try_complete_twice
    promise = Dharma.promise

    assert promise.try_complete(1)
    assert !promise.try_complete(2)
    assert_equal 1, promise.result
  end

  def test_completing_with_an_exception
    promise = Dharma.promise

    promise.try_complete(Exception.new('broken'))

    assert promise.failure?
  end
end
