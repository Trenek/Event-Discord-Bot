defmodule CreateCommand do
  alias Nostrum.Api

  alias Nostrum.Api.ScheduledEvent
  alias Nostrum.Api.Message
  alias Nostrum.Api.Interaction

  alias Nostrum.Struct.Interaction

  def create do
    %{
      name: "stworz",
      description: "Stwórz nową propozycję egzaminu",
      options: [
        %{
          type: Nostrum.Constants.ApplicationCommandOptionType.string(),
          name: "nazwa",
          description: "Podaj nazwę egzaminu",
          required: true
        },

        %{
          type: Nostrum.Constants.ApplicationCommandOptionType.string(),
          name: "start",
          description: "Podaj datę rozpoczęcia",
          required: true,
        },

        %{
          type: Nostrum.Constants.ApplicationCommandOptionType.string(),
          name: "end",
          description: "Podaj datę zakończenia",
          required: false,
        },

        %{
          type: Nostrum.Constants.ApplicationCommandOptionType.string(),
          name: "opis",
          description: "Wprowadź opis",
          required: false
        },

        %{
          type: Nostrum.Constants.ApplicationCommandOptionType.string(),
          name: "sala",
          description: "Podaj salę",
          required: false,
        }
      ]
    }
  end

  defp event_name([%{ name: "nazwa", value: nazwa } | _]), do: nazwa
  defp event_name([_ | tail]), do: event_name(tail)

  defp event_description([%{ name: "opis", value: opis } | _]), do: opis
  defp event_description([_ | tail]), do: event_description(tail)
  defp event_description(_), do: ""

  defp event_sala([%{ name: "sala", value: sala } | _]), do: sala
  defp event_sala([_ | tail]), do: event_sala(tail)
  defp event_sala(_), do: "???"

  defp event_start([%{ name: "start", value: start } | _]), do: DateTime.from_iso8601(start)
  defp event_start([_ | tail]),                             do: event_start(tail)
  defp event_start(_),                                      do: { :brak }

  defp event_eend([%{ name: "end", value: eend } | _]),     do: DateTime.from_iso8601(eend)
  defp event_eend([_ | tail]),                              do: event_eend(tail)
  defp event_eend(_),                                       do: { :brak }

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

  def handle_event(itr) do
    message_str = case event_start(itr.data.options) do
      {:ok, data, _} -> 
        Message.create(itr.channel_id, [
          content: "Nowa Propozycja",
          components: [
            button_list([
              description_button("Nazwa", "name_desc"),
              info_button(event_name(itr.data.options), "name") 
            ]),
            button_list("Opis", "desc_desc", case descr = event_description(itr.data.options) do
              "" -> []
              _  -> [ info_button(descr, "desc") ]
            end),
            button_list("Przedział Czasowy", "time_desc", [
              info_button(Common.date_to_string(data), "start"),
              info_button(Common.date_to_string(case event_eend(itr.data.options) do
                {:ok, end_data, _} -> end_data
                _                  -> DateTime.add(data, 1, :hour)
              end), "end")
            ]),
            button_list("Sala", "sala_desc", [
              info_button(event_sala(itr.data.options), "sala")
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
        ])
        "Wszystko Oki"
      _ -> "Niepoprawny format daty"
    end

    Api.Interaction.create_response(itr, %{
      type: 4,
      data: %{
        content: message_str,
        flags: 64
      }
    })
  end
end
