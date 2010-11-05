class ChatPostAction < Cramp::Action
  on_start :retrieve_chats

  def retrieve_chats 
    render "Got your #{data}"
    finish
  end
end
