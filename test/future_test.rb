require 'test_helper'

class FutureTest < Test::Unit::TestCase
  def test_future
    promise = Dharma.future() { true }
    
    assert promise.completed?
    assert promise.result
  end
end
