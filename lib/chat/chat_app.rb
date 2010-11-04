class WelcomeAction < Cramp::Controller::Action
  on_start :send_hello_world

  def send_hello_world
    render "Hello World"
    finish
  end
end
