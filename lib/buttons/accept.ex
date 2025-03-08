defmodule AcceptButton do
  defp get_component(nazwa, components, num) do
    case (hd (hd components).components).label do
       ^nazwa -> case val = Enum.at((hd components).components, num) do
         nil -> nil
         _ -> val.label
       end
       _ -> get_component(nazwa, (tl components), num)
    end
  end

  def handle_event(itr) do
    message = itr.message.components
    message_str = case Nostrum.Api.ScheduledEvent.create(itr.guild_id, [
      name: get_component("Nazwa", message, 1),
      privacy_level: 2,
      scheduled_start_time: get_component("Przedział Czasowy", message, 1),
      scheduled_end_time: get_component("Przedział Czasowy", message, 2),
      description: case val = get_component("Opis", message, 1) do
        nil -> ""
        _ -> val
      end,
      entity_type: 3,
      entity_metadata: %{
        location: get_component("Sala", message, 1)
      }
    ]) do
      { :ok, x } -> 
        IO.puts("One") 
        IO.inspect(x)
        IO.puts("Two") 
        IO.inspect(itr)
        Nostrum.Api.Message.edit(itr.channel_id, itr.message.id, %{
          content: "Zaakceptowany" ++ Integer.to_string(x.id)
        })
        "Wydarzenie Stworzone"
      _ -> "Błąd"
    end


    Nostrum.Api.Interaction.create_response(itr, %{
      type: 4,
      data: %{
        content: message_str,
        flags: 64
      }
    })
  end
end
