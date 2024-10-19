defmodule Songanote.Transcription.Workspace do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    extensions: [AshArchival.Resource]

  resource do
    description """
    Represents a workspace.
    Each workspace may contain a transcription result, a file object
    """
  end

  postgres do
    repo Songanote.Repo
    table "workspaces"

    references do
      reference :organization, on_delete: :delete
    end

    custom_indexes do
      index [:organization_id]
      index [:user_id]
      index [:id]
      index [:status]
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true

      filter expr(id == ^arg(:id))
    end

    read :default_read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    create :new do
      accept [
        :name,
        :file,
        :user_id,
        :organization_id
      ]
    end

    update :update_workspace do
      accept [:name, :status]
      primary? true
    end

    destroy :soft_delete do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      description "The name of the workspace"

      allow_nil? false
    end

    attribute :user_id, :uuid do
      description "The id of the user that created the workspace"

      allow_nil? false
    end

    attribute :organization_id, :uuid do
      description "The organization this membership belongs to"

      allow_nil? false
    end

    attribute :file, Songanote.File do
      description "The audio file of the workspace"

      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:active, :inactive]

      default :active
      description "The status of the workspace"
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  pub_sub do
    module Songanote
    prefix "workspace"
    broadcast_type :phoenix_broadcast

    publish :create, ["created", [:user_id, nil]]
    publish :update, ["updated", :id]

    publish_all :create, "created"
  end

  relationships do
    belongs_to :organization, Songanote.Accounts.Organization

    has_one :transcription_result, Songanote.Transcription.TranscriptionResult do
      destination_attribute :workspace_id
    end

    has_one :transcription_task, Songanote.Transcription.Task do
      destination_attribute :workspace_id
    end
  end
end
