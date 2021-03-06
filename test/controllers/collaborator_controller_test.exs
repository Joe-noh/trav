defmodule Trav.CollaboratorControllerTest do
  use Trav.ConnCase, async: true

  alias Trav.{UserFactory, TripFactory, CollaborationFactory}
  alias Trav.{User, Trip, JWT}

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.checkout(Trav.Repo)

    user = UserFactory.create(:user)
    collaborator = UserFactory.create(:user)
    trip = TripFactory.create(:trip, user: user)
    CollaborationFactory.create(:collaboration, trip: trip, user: collaborator)

    conn = conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", user |> JWT.encode |> JWT.bearer)

    {:ok, [
      conn: conn,
      trip: trip,
      user: user,
      collaborator: collaborator
    ]}
  end

  test "POST a collaborator", %{conn: conn, trip: trip} do
    another_user = UserFactory.create(:user)
    response = conn
      |> post(trip_collaborator_path(conn, :create, trip), collaborator_id: another_user.id)
      |> json_response(201)

    assert response["user"]
  end

  test "POST twice doesn't change num of collaborators", %{conn: conn, trip: trip} do
    another_user = UserFactory.create(:user)
    num_collaborators = collaborators(trip) |> length

    conn |> post(trip_collaborator_path(conn, :create, trip), collaborator_id: another_user.id)
    assert trip |> collaborators |> length == num_collaborators+1

    conn |> post(trip_collaborator_path(conn, :create, trip), collaborator_id: another_user.id)
    assert trip |> collaborators |> length == num_collaborators+1
  end

  test "only owner can add collaborators", %{conn: conn, trip: trip} do
    another_user = UserFactory.create(:user)

    response = conn
      |> put_req_header("authorization", another_user |> JWT.encode |> JWT.bearer)
      |> post(trip_collaborator_path(conn, :create, trip), collaborator_id: another_user.id)
      |> json_response(401)

    assert response["errors"] != %{}
  end

  test "DELETE a collaborator", %{conn: conn, trip: trip, collaborator: collaborator} do
    num_users = Repo.one(from u in User, select: count(u.id))
    num_collaborators = collaborators(trip) |> length

    response = conn
      |> delete(trip_collaborator_path(conn, :delete, trip, collaborator))
      |> response(204)

    assert response == ""
    assert trip |> collaborators |> length == num_collaborators-1
    refute collaborator.id in (trip |> collaborators |> Enum.map(& &1.id))
    assert Repo.one(from u in User, select: count(u.id)) == num_users
  end

  test "deleting an not-collaborator-user from collaborators returns 204", %{conn: conn, trip: trip} do
    another_user = UserFactory.create(:user)
    num_collaborators = collaborators(trip) |> length

    conn
    |> delete(trip_collaborator_path(conn, :delete, trip, another_user))
    |> response(204)

    assert trip |> collaborators |> length == num_collaborators
  end

  test "only owner can delete collaborators", %{conn: conn, trip: trip, collaborator: collaborator} do
    another_user = UserFactory.create(:user)

    response = conn
      |> put_req_header("authorization", another_user |> JWT.encode |> JWT.bearer)
      |> delete(trip_collaborator_path(conn, :delete, trip, collaborator))
      |> json_response(401)

    assert response["errors"] != %{}
  end

  defp collaborators(trip) do
    Repo.get(Trip, trip.id) |> Repo.preload(:collaborators) |> Map.get(:collaborators)
  end
end
