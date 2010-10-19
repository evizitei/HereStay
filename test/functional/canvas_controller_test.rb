require 'test_helper'

class CanvasControllerTest < ActionController::TestCase
  should "successfully route asset canvas to the canvas page" do
    assert_routing "/canvas",{:controller=>"canvas",:action=>"index"}
  end
end
