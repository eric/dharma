require 'test_helper'

class PromiseActionsTest < Test::Unit::TestCase
  def test_on_complete_assigned_before
    promise = Dharma.promise
    
    result = nil
    
    promise.on_complete do |value, as|
      result = value
    end
    
    promise.try_complete(1)
    
    assert promise.completed?
    assert_equal 1, result
    assert_equal 1, promise.result
  end
  
  def test_on_complete_assigned_after
    promise = Dharma.promise
    
    result = nil
    
    promise.try_complete(1)
    
    promise.on_complete do |value, as|
      result = value
    end
    
    assert promise.completed?
    assert_equal 1, result
    assert_equal 1, promise.result
  end
  
  def test_on_success_callback
    promise = Dharma.promise
    
    result = nil
    
    promise.on_success do |value|
      result = value
    end
    
    promise.try_complete(1)
    
    assert promise.completed?
    assert_equal 1, result
  end
  
  def try_complete_with
    p1 = Dharma.promise
    p2 = Dharma.promise
    
    p2.complete_with(p1)
    
    p1.complete(1)
    
    assert_equal 1, p2.result
  end
end
