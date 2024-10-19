defmodule Songanote.File do
  use Ash.Resource,
    data_layer: :embedded

  resource do
    description """
    Represents a file object
    """
  end

  attributes do
    attribute :filename, :string,
      description: "The system issued filename when upload is complete"

    attribute :original_filename, :string, description: "The filename from client device"

    attribute :mime, :string, description: "The mime type of the file"
    attribute :size, :integer, description: "The size of the file in bytes"
    attribute :blurhash, :string, description: "A blurhash string if the file is an image"
    attribute :thumbnail, :string, description: "A thumbnail url  if the file is a video"
    attribute :ext, :string, description: "The extension of the file"

    attribute :dimensions, :map,
      description: "The width and height of the file if its an image or video"

    attribute :audio_stats, :map,
      description: "The ID3 Tag information found in the file if its audio"
  end
end
