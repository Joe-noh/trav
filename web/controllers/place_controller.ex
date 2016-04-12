defmodule Trav.PlaceController do
  use Trav.Web, :controller

  alias Trav.{Place, Trip}

  plug Trav.Plugs.CheckAuthPlug
  plug :scrub_params, "place" when action in [:create, :update]
  plug :correct_user

  def index(conn, _params) do
    places = Repo.all(Place)
    render(conn, "index.json", places: places)
  end

  def create(conn, %{"trip_id" => trip_id, "place" => place_params}) do
    trip = Repo.one!(from t in Trip, where: t.id == ^trip_id, preload: :map)
    changeset = trip.map
      |> build_assoc(:places)
      |> Place.changeset(place_params)

    case Repo.insert(changeset) do
      {:ok, place} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", trip_place_path(conn, :show, trip, place))
        |> render("show.json", place: place)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Trav.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    place = Repo.get!(Place, id)
    render(conn, "show.json", place: place)
  end

  def update(conn, %{"id" => id, "place" => place_params}) do
    place = Repo.get!(Place, id)
    changeset = Place.changeset(place, place_params)

    case Repo.update(changeset) do
      {:ok, place} ->
        render(conn, "show.json", place: place)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Trav.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Place |> Repo.get!(id) |> Repo.delete!

    send_resp(conn, :no_content, "")
  end

  defp correct_user(conn, _opts) do
    trip_id = conn.params |> Map.get("trip_id") |> String.to_integer
    trip = Repo.one(from t in Trip, where: t.id == ^trip_id, preload: :user)

    if conn.assigns.current_user.id == trip.user.id do
      conn
    else
      conn |> unauthorized
    end
  end
end