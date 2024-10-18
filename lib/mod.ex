defmodule Songanote.Services.TranscribeAudio do
  @moduledoc """
  Starts a transcribe audio process.
  """
  use Reactor

  alias Songanote.Services.{
    CreateWorkspaceStep,
    CreateTranscriptionTaskStep,
    StartAssemblyaiTranscriptionStep,
    CreateNotificationStep
  }

  input :audio_url
  input :organization_id
  input :name
  input :user
  input :file

  step :create_workspace, CreateWorkspaceStep do
    argument :name, input(:name)
    argument :file, input(:file)
    argument :organization_id, input(:organization_id)
    argument :user_id, input(:user, [:id])
  end

  step :start_assemblyai_transcription, StartAssemblyaiTranscriptionStep do
    argument :audio_url, input(:audio_url)

    argument :workspace_id, result(:create_workspace) do
      transform(& &1.id)
    end
  end

  # debug :debug do
  #   argument :asssemblyai_response, result(:start_assemblyai_transcription)
  # end

  step :create_transcription_task, CreateTranscriptionTaskStep do
    argument :workspace_id, result(:create_workspace) do
      transform(& &1.id)
    end

    argument :assemblyai_id, result(:start_assemblyai_transcription) do
      transform(&Map.get(&1, "id"))
    end

    argument :status, result(:start_assemblyai_transcription) do
      transform(&Map.get(&1, "status"))
    end
  end

  step :create_notification_message, CreateNotificationStep do
    argument :title, value("New audio transcription")

    argument :message, result(:create_workspace) do
      transform(
        &("A new audio transcription request has been queued for your workspace - " <>
            &1.name)
      )
    end

    argument :type, value(:general)
    argument :sender, value(:system)

    argument :organization_id, result(:create_workspace, [:organization_id])
    argument :workspace_id, result(:create_workspace, [:id])
  end

  return(:create_workspace)
end
