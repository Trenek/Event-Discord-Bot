defmodule EditCommand do
  alias Nostrum.Api

  alias Nostrum.Api.ScheduledEvent
  alias Nostrum.Api.Message
  alias Nostrum.Api.Interaction

  alias Nostrum.Struct.Interaction

  def create do
    %{
      name: "edit",
      description: "Zmień Szczegóły",
      options: [
        %{
          type: 3,
          name: "id",
          description: "Podaj id",
          required: true
        },
        %{ 
          type: 3,
          name: "nazwa",
          description: "Podaj nową nazwę",
          required: false
        },

        %{
          type: 3,
          name: "start",
          description: "Podaj nową datę rozpoczęcia",
          required: false,
        },

        %{
          type: 3,
          name: "end",
          description: "Podaj nową datę zakończenia",
          required: false,
        },

        %{
          type: 3,
          name: "opis",
          description: "Podaj nowy opis",
          required: false
        },

        %{
          type: 3,
          name: "sala",
          description: "Podaj nową salę",
          required: false,
        }
      ]
    }
  end

  defp event_id([%{ name: "id", value: nazwa } | _]), do: nazwa
  defp event_id([_ | tail]), do: event_id(tail)

  defp modify(guild_id, id, [head | tail]) do
    case modify(guild_id, id, tail) do
      :ok -> case head do
        %{ name: "id", value: _ } -> :ok
        %{ name: "nazwa", value: val } ->
          ScheduledEvent.modify(guild_id, id, [ name: val ])
          :ok
        %{ name: "opis",  value: val } -> 
          ScheduledEvent.modify(guild_id, id, [ description: val ]) 
          :ok
        %{ name: "sala",  value: val } ->
          ScheduledEvent.modify(guild_id, id, [ entity_metadata: %{ location: val } ])
          :ok
        %{ name: "start", value: val } -> case DateTime.from_iso8601(val) do
          {:ok, date, _} -> 
            ScheduledEvent.modify(guild_id, id, [ scheduled_start_time: date ])
            :ok
          _ -> :notOk
        end
        %{ name: "end",   value: val } -> case DateTime.from_iso8601(val) do
          {:ok, date, _} -> 
            ScheduledEvent.modify(guild_id, id, [ scheduled_end_time:   date ])
            :ok
          _ -> :notOk
        end
      end
      _ -> :notOk
    end
  end
  defp modify(_, _, _), do: :ok

  def handle_event(itr) do
    message_str = case modify(itr.guild_id, event_id(itr.data.options), itr.data.options) do
      :ok -> "Wszystko jest OK"
      _ -> "Wystąpiły błędy"
    end

    message = %{
      type: 4,
      data: %{
        content: message_str,
        flags: 64 # not visible
      }
    }

    Api.Interaction.create_response(itr, message)
  end
end
