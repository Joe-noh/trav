defmodule Trav.User do
  use Trav.Web, :model

  schema "users" do
    field :name,         :string
    field :access_token, :string

    timestamps
  end

  @allowed ~w(name access_token)

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, @allowed)
    |> validate_required(:name)
    |> validate_required(:access_token)
  end
end
