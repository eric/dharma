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
end
