defmodule EditModal do
  defp inputBox(name, id, placeholder, isRequired, value), do: %{
    type: Nostrum.Constants.ComponentType.action_row(),
    components: [
      %{
        type: Nostrum.Constants.ComponentType.text_input(),
        custom_id: id,
        label: name,
        style: Nostrum.Constants.TextInputStyle.short(),
        min_length: case isRequired do
          true -> 1
          false -> 0
        end,
        max_length: 80,
        placeholder: placeholder,
        required: isRequired,
        value: value
      }
    ]
  }
  
  defp get_component(nazwa, components, num) do
    case (hd (hd components).components).label do
       ^nazwa -> case val = Enum.at((hd components).components, num) do
         nil -> nil
         _ -> val.label
       end
       _ -> get_component(nazwa, (tl components), num)
    end
  end

  def create(itr) do
    message = itr.message.components
    Nostrum.Api.Interaction.create_response(itr, %{
      type: Nostrum.Constants.InteractionCallbackType.modal(),
      data: %{
        title: "Edytuj Wydarzenie",
        custom_id: "edit_modal",
        components: [
          inputBox("Nazwa Wydarzenia", "name", "Nazwa", true, get_component("Nazwa", message, 1)),
          inputBox("Opis Wydarzenia", "description", "Opis", false, get_component("Opis", message, 1)),
          inputBox("Start Wydarzenia", "start", "27-04-2077 15:21:00+02", true, get_component("Przedział Czasowy", message, 1)),
          inputBox("Koniec Wydarzenia", "end", "27-04-2077 15:21:00+02", true, get_component("Przedział Czasowy", message, 2)),
          inputBox("Sala Wydarzenia", "sala", "Sala", true, get_component("Sala", message, 1))
        ]
      }
    })
  end

  defp description_button(nazwa, id), do: %{
    type: Nostrum.Constants.ComponentType.button(),
    label: nazwa,
    style: Nostrum.Constants.ButtonStyle.secondary(),
    custom_id: id,
    disabled: true
  }

  defp info_button(nazwa, id), do: %{
    type: Nostrum.Constants.ComponentType.button(),
    label: nazwa,
    style: Nostrum.Constants.ButtonStyle.success(),
    custom_id: id,
    disabled: true
  }

  defp button_list(nazwa, id, list), do: button_list([ description_button(nazwa, id) | list ])
  defp button_list(list), do: %{
    type: Nostrum.Constants.ComponentType.action_row(),
    components: list
  }

  defp getData(list, name) do
    case (hd (hd list).components).custom_id do
      ^name -> (hd (hd list).components).value
      _ -> getData((tl list), name)
    end
  end

  def handle_event(itr) do
    ms = with \
      { :ok, start_date, _ } <- DateTime.from_iso8601(getData(itr.data.components, "start")),
      { :ok, end_date, _ } <- DateTime.from_iso8601(getData(itr.data.components, "end")) do
      Nostrum.Api.Message.edit(itr.message, %{
        components: [
          button_list("Nazwa", "name_desc", [
            info_button(getData(itr.data.components, "name"), "name") 
          ]),
          button_list("Opis", "desc_desc", case val = (getData(itr.data.components, "description")) do
            nil -> []
            "" -> []
            _ -> [ info_button(val, "desc") ]
          end),
          button_list("Przedział Czasowy", "time_desc", [
            info_button(Common.date_to_string(start_date), "start"),
            info_button(Common.date_to_string(end_date), "end")
          ]),
          button_list("Sala", "sala_desc", [
            info_button(getData(itr.data.components, "sala"), "sala")
          ]),
          button_list([
            %{
              type: Nostrum.Constants.ComponentType.button(),
              label: "Zaakceptuj",
              style: Nostrum.Constants.ButtonStyle.success(),
              custom_id: "accept_id"
            },
            %{
              type: Nostrum.Constants.ComponentType.button(),
              label: "Odrzuć",
              style: Nostrum.Constants.ButtonStyle.danger(),
              custom_id: "deny_id"
            },
            %{
              type: Nostrum.Constants.ComponentType.button(),
              label: "Edytuj",
              style: Nostrum.Constants.ButtonStyle.primary(),
              custom_id: "edit_id"
            }
          ])
        ]
      })
      "Wszystko Oki"
      else _ -> "Niepoprawny Format Daty"
    end
    Nostrum.Api.Interaction.create_response(itr, %{
      type: 4,
      data: %{
        content: ms,
        flags: 64
      }
    })
  end
end
