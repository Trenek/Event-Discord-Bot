defmodule ExampleSupervisor do
  use Supervisor

  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(_init_arg) do
    children = [ExampleConsumer]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule ExampleConsumer do
  use Nostrum.Consumer
  alias Nostrum.Constants.InteractionType

  def handle_event({:READY, _ready, _ws_state}) do
    Nostrum.Api.ApplicationCommand.bulk_overwrite_guild_commands(798567956455227392, [
      CreateCommand.create(),
    ])
  end

  def handle_event({:INTERACTION_CREATE, itr, _ws_state}) do
    commandType = InteractionType.application_command()
    buttonType = InteractionType.message_component()
    modalType = InteractionType.modal_submit()

    case itr.type do
      ^commandType -> case itr.data.name do
        "stworz" -> CreateCommand.handle_event(itr)
      end
      ^buttonType -> case itr.data.custom_id do
        "edit_id" -> EditModal.create(itr)
        "accept_id" -> AcceptButton.handle_event(itr)
        "deny_id" -> DenyButton.handle_event(itr)
      end
      ^modalType -> case itr.data.custom_id do
        "edit_modal" -> EditModal.handle_event(itr)
      end
    end
  end
end
