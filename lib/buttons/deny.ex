defmodule DenyButton do
  def handle_event(itr) do
    Nostrum.Api.Message.delete(itr.message)
 
    Nostrum.Api.Interaction.create_response(itr, %{
      type: 4,
      data: %{
        content: "Wydarzenie Usunięte",
        flags: 64
      }
    })
  end
end
