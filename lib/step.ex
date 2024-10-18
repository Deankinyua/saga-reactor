defmodule Songanote.Services.CreateWorkspaceStep do
  @moduledoc """
  Creates a new workspace
  """
  use Reactor.Step

  alias Songanote.Transcription

  @impl true
  def run(arguments, _context, _options) do
    Transcription.Workspace
    |> Ash.Changeset.for_create(:create, %{
      name: arguments.name,
      file: arguments.file,
      user_id: arguments.user_id,
      organization_id: arguments.organization_id
    })
    |> Transcription.create()
  end

  @impl true
  def undo(workspace, _arguments, _context, _options) do
    case workspace
         |> Ash.Changeset.for_destroy(:soft_delete)
         |> Transcription.destroy() do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
      _ -> :ok
    end
  end
end


# this might be necessary too


# def compensate("network error" <> _rest, _arguments, _context, _options) do
#   :retry
# end

# def compensate(_error, _arguments, _context, _options) do
#   :ok
# end
