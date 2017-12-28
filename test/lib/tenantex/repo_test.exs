defmodule Tenantex.RepoTest do
  use ExUnit.Case
  import Tenantex.Queryable
  import Mock
  alias Tenantex.{Note,Tag,TenantMissingError}
  alias Tenantex.Test.{TenantedRepo,UntenantedRepo,ProcessTenantedRepo}

  @tenant_id 2
  @error_message "No tenant specified in Elixir.Tenantex.Note"
  @prefix "TENANTEX_PREFIX"

  def scoped_note_query do
    Note
    |> Ecto.Queryable.to_query
    |> set_tenant(@tenant_id)
  end

  def scoped_note do
    %Note{id: 1, body: "body"} |> set_tenant(@tenant_id)
  end

  def scoped_changeset do
    Note.changeset(scoped_note(), %{body: "body"})
  end


  setup do
    on_exit fn -> Process.delete(@prefix) end
  end

  test ".all/2 verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.all(Note, [])
    end

    with_mock Ecto.TestRepo, [all: fn(struct, []) -> [1] end] do
      assert TenantedRepo.all(scoped_note_query(), []) == [1]
    end

    with_mock Ecto.TestRepo, [all: fn(Note, [prefix: "tenant_test"]) -> [1] end] do
      assert TenantedRepo.all(Note, [prefix: "test"]) == [1]
    end

    with_mock Ecto.TestRepo, [all: fn(Note, []) -> [1] end] do
      assert UntenantedRepo.all(Note, []) == [1]
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.all(Note, [])
    end
    with_mock Ecto.TestRepo, [all: fn(Tag, []) -> [1] end] do
      assert ProcessTenantedRepo.all(Tag, []) == [1]
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [all: fn(Tenantex.Note, [prefix: "tenant_test"]) -> [1] end] do
      assert ProcessTenantedRepo.all(Note, []) == [1]
    end
  end

  test ".stream/2 verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.stream(Note, [])
    end
    with_mock Ecto.TestRepo, [stream: fn(struct, []) -> [1] end] do
      assert TenantedRepo.stream(scoped_note_query(), []) |> Enum.to_list == [1]
    end

    with_mock Ecto.TestRepo, [stream: fn(struct, [prefix: "tenant_test"]) -> [1] end] do
      assert TenantedRepo.stream(Note, [prefix: "test"]) |> Enum.to_list == [1]
    end

    with_mock Ecto.TestRepo, [stream: fn(struct, []) -> [1] end] do
      assert UntenantedRepo.stream(Note, []) |> Enum.to_list == [1]
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.stream(Note, []) |> Enum.to_list
    end
    with_mock Ecto.TestRepo, [stream: fn(struct, []) -> [1] end] do
      assert ProcessTenantedRepo.stream(Tag, []) |> Enum.to_list == [1]
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [stream: fn(struct, [prefix: "tenant_test"]) -> [1] end] do
      assert ProcessTenantedRepo.stream(Note, []) |> Enum.to_list == [1]
    end
  end

  test ".get/2 verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.get(Note, 1)
    end

    with_mock Ecto.TestRepo, [get: fn(any, 1, []) -> 1 end] do
      assert TenantedRepo.get(scoped_note_query(), 1) == 1
    end

    with_mock Ecto.TestRepo, [get: fn(Note, 1, [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.get(Note, 1, [prefix: "test"]) == 1
    end

    with_mock Ecto.TestRepo, [get: fn(Note, 1, []) -> 1 end] do
      assert UntenantedRepo.get(Note, 1) == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.get(Note, 1)
    end

    with_mock Ecto.TestRepo, [get: fn(Tag, 1, []) -> 1 end] do
      assert ProcessTenantedRepo.get(Tag, 1) == 1
    end
    Process.put(@prefix, "test")

    with_mock Ecto.TestRepo, [get: fn(Note, 1, [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.get(Note, 1) == 1
    end
  end

  test ".get!/2 verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.get(Note, 1)
    end

    with_mock Ecto.TestRepo, [get!: fn(queryable, 1, []) -> 1 end] do
      assert TenantedRepo.get!(scoped_note_query(), 1) == 1
    end
    with_mock Ecto.TestRepo, [get!: fn(Note, 1, [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.get!(Note, 1, [prefix: "test"]) == 1
    end
    with_mock Ecto.TestRepo, [get!: fn(Note, 1, []) -> 1 end] do
      assert UntenantedRepo.get!(Note, 1) == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.get!(Note, 1)
    end
    with_mock Ecto.TestRepo, [get!: fn(Tag, 1, []) -> 1 end] do
      assert ProcessTenantedRepo.get!(Tag, 1) == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [get!: fn(Note, 1, [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.get!(Note, 1) == 1
    end
  end

  test ".get_by(queryable, clauses, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.get_by(Note, body: "immaterial")
    end

    with_mock Ecto.TestRepo, [get_by: fn(queryable, [body: "immaterial"], []) -> 1 end] do
      assert TenantedRepo.get_by(scoped_note_query(), body: "immaterial") == 1
    end
    with_mock Ecto.TestRepo, [get_by: fn(Note, [body: "immaterial"], [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.get_by(Note, [body: "immaterial"], [prefix: "test"]) == 1
    end
    with_mock Ecto.TestRepo, [get_by: fn(Note, [body: "immaterial"], []) -> 1 end] do
      assert UntenantedRepo.get_by(Note, body: "immaterial") == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.get_by(Note, body: "immaterial")
    end
    with_mock Ecto.TestRepo, [get_by: fn(Tag, [name: "immaterial"], []) -> 1 end] do
      assert ProcessTenantedRepo.get_by(Tag, name: "immaterial") == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [get_by: fn(Note, [body: "immaterial"], [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.get_by(Note, body: "immaterial") == 1
    end
  end

  test ".get_by!(queryable, clauses, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.get_by!(Note, body: "immaterial")
    end

    with_mock Ecto.TestRepo, [get_by!: fn (queryable, [body: "immaterial"], []) -> 1 end] do
      assert TenantedRepo.get_by!(scoped_note_query(), body: "immaterial") == 1
    end
    with_mock Ecto.TestRepo, [get_by!: fn (Note, [body: "immaterial"], [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.get_by!(Note, [body: "immaterial"], [prefix: "test"]) == 1
    end
    with_mock Ecto.TestRepo, [get_by!: fn (Note, [body: "immaterial"], []) -> 1 end] do
      assert UntenantedRepo.get_by!(Note, body: "immaterial") == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.get_by!(Note, body: "immaterial")
    end
    with_mock Ecto.TestRepo, [get_by!: fn (Tag, [name: "immaterial"], []) -> 1 end] do
      assert ProcessTenantedRepo.get_by!(Tag, name: "immaterial") == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [get_by!: fn (Note, [body: "immaterial"], [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.get_by!(Note, body: "immaterial") == 1
    end
  end

  test ".one(queryable, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.one(Note)
    end

    with_mock Ecto.TestRepo, [one: fn (queryable, []) -> 1 end] do
      assert TenantedRepo.one(scoped_note_query()) == 1
    end
    with_mock Ecto.TestRepo, [one: fn (Note, [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.one(Note, [prefix: "test"]) == 1
    end
    with_mock Ecto.TestRepo, [one: fn (Note, []) -> 1 end] do
      assert UntenantedRepo.one(Note) == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.one(Note)
    end
    with_mock Ecto.TestRepo, [one: fn (Tag, []) -> 1 end] do
      assert ProcessTenantedRepo.one(Tag) == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [one: fn (Note, [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.one(Note) == 1
    end
  end


  test ".one!(queryable, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.one!(Note)
    end

    with_mock Ecto.TestRepo, [one!: fn (queryable, []) -> 1 end] do
      assert TenantedRepo.one!(scoped_note_query()) == 1
    end
    with_mock Ecto.TestRepo, [one!: fn (Note, [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.one!(Note, [prefix: "test"]) == 1
    end
    with_mock Ecto.TestRepo, [one!: fn (Note, []) -> 1 end] do
      assert UntenantedRepo.one!(Note) == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.one!(Note)
    end
    with_mock Ecto.TestRepo, [one!: fn (Tag, []) -> 1 end] do
      assert ProcessTenantedRepo.one!(Tag) == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [one!: fn (Note, [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.one!(Note) == 1
    end
  end

  test ".preload(struct_or_structs, preloads, opts \\ [])" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.preload(%Note{}, :tags)
    end

    note = Ecto.put_meta(%Note{}, prefix: "tenant_test")
    assert TenantedRepo.preload(note, :tags)
    assert TenantedRepo.preload([note], :tags)
    assert UntenantedRepo.preload(%Note{}, :tags)

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.preload(%Note{}, :tags)
    end
    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.preload([%Note{}], :tags)
    end
    assert ProcessTenantedRepo.preload(note, :tags)
    assert ProcessTenantedRepo.preload([note], :tags)
    assert_raise TenantMissingError, @error_message, fn ->
      # If the opts are not provided, then EVERY model
      # needs the prefix to be set
      ProcessTenantedRepo.preload([note, %Note{}], :tags)
    end
    Process.put(@prefix, "test")
    assert ProcessTenantedRepo.preload(%Note{}, :tags)
    assert ProcessTenantedRepo.preload([%Note{}], :tags)
  end

  test ".aggregate(queryable, aggregate, field, opts \\ [])" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.aggregate(Note, :avg, :body)
    end

    with_mock Ecto.TestRepo, [aggregate: fn(queryable, :avg, :body, []) -> 1 end] do
      assert TenantedRepo.aggregate(scoped_note_query(), :avg, :body) == 1
    end
    with_mock Ecto.TestRepo, [aggregate: fn(Note, :avg, :body, [prefix: "tenant_test"]) -> 1 end] do
      assert TenantedRepo.aggregate(Note, :avg, :body, prefix: "test") == 1
    end
    with_mock Ecto.TestRepo, [aggregate: fn(Note, :avg, :body, []) -> 1 end] do
      assert UntenantedRepo.aggregate(Note, :avg, :body) == 1
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.aggregate(Note, :avg, :body) == 1
    end
    with_mock Ecto.TestRepo, [aggregate: fn(Tag, :avg, :name, []) -> 1 end] do
      assert ProcessTenantedRepo.aggregate(Tag, :avg, :name) == 1
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [aggregate: fn(Note, :avg, :body, [prefix: "tenant_test"]) -> 1 end] do
      assert ProcessTenantedRepo.aggregate(Note, :avg, :body) == 1
    end
  end

  test ".insert_all(schema_or_source, entries, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      TenantedRepo.insert_all(Note, [%Note{body: "body0"}])
    end
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      TenantedRepo.insert_all("notes", [%Note{body: "body0"}])
    end
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      TenantedRepo.insert_all({nil, "notes"}, [%Note{body: "body0"}])
    end
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      TenantedRepo.insert_all({nil, Note}, [%Note{body: "body0"}])
    end

    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      TenantedRepo.insert_all(:note, [%Note{body: "body0"}])
    end

    with_mock Ecto.TestRepo, [insert_all: fn({@tenant_id, "notes"}, [%{body: "body"}], []) -> {1, nil} end] do
      assert TenantedRepo.insert_all({@tenant_id, "notes"}, [%{body: "body"}]) == {1, nil}
    end
    with_mock Ecto.TestRepo, [insert_all: fn({@tenant_id, Note}, [%{body: "body"}], []) -> {1, nil} end] do
      assert TenantedRepo.insert_all({@tenant_id, Note}, [%{body: "body"}]) == {1, nil}
    end

    with_mock Ecto.TestRepo, [insert_all: fn(Note, [%{body: "body0"}], [prefix: "tenant_test"]) -> {1, nil} end] do
      assert TenantedRepo.insert_all(Note, [%{body: "body0"}], [prefix: "test"]) == {1, nil}
    end

    with_mock Ecto.TestRepo, [insert_all: fn(Note, [%{body: "body0"}], []) -> {1, nil} end] do
      assert UntenantedRepo.insert_all(Note, [%{body: "body0"}]) == {1, nil}
    end

    Process.put(@prefix, "test")

    with_mock Ecto.TestRepo, [insert_all: fn(Note, [%{body: "body0"}], [prefix: "tenant_test"]) -> {1, nil} end] do
      ProcessTenantedRepo.insert_all(Note, [%{body: "body0"}]) == {1, nil}
    end
    with_mock Ecto.TestRepo, [insert_all: fn({nil, Note}, [%{body: "body0"}], [prefix: "tenant_test"]) -> {1, nil} end] do
      ProcessTenantedRepo.insert_all({nil, Note}, [%{body: "body0"}]) == {1, nil}
    end
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      ProcessTenantedRepo.insert_all(:note, [%Note{body: "body0"}])
    end
    assert_raise TenantMissingError, ~r/For insert_all/, fn ->
      ProcessTenantedRepo.insert_all({nil,"notes"}, [%Note{body: "body0"}])
    end
  end

  test ".update_all(queryable, updates, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.update_all(Note, set: [body: "new"])
    end

    with_mock Ecto.TestRepo, [update_all: fn(queryabl, [set: [body: "new"]], []) -> {1, nil} end] do
      assert TenantedRepo.update_all(scoped_note_query(), set: [body: "new"])
    end

    with_mock Ecto.TestRepo, [update_all: fn(Note, [set: [body: "new"]], [prefix: "tenant_test"]) -> {1, nil} end] do
      assert TenantedRepo.update_all(Note, [set: [body: "new"]], [prefix: "test"]) == {1, nil}
    end

    with_mock Ecto.TestRepo, [update_all: fn(Note, [set: [body: "new"]], []) -> {1, nil} end] do
      assert UntenantedRepo.update_all(Note, set: [body: "new"]) == {1, nil}
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.update_all(Note, set: [body: "new"])
    end
    with_mock Ecto.TestRepo, [update_all: fn(Tag, [set: [name: "new"]], []) -> {1, nil} end] do
      assert ProcessTenantedRepo.update_all(Tag, set: [name: "new"])
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [update_all: fn(Note, [set: [body: "new"]], [prefix: "tenant_test"]) -> {1, nil} end] do
      assert ProcessTenantedRepo.update_all(Note, set: [body: "new"])
    end
  end




# TODO - THIS IS WHERE I LEFT OFF MOCKING OUT ALL THIS CRAP




  test ".delete_all(queryable, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.delete_all(Note)
    end

    with_mock Ecto.TestRepo, [delete_all: fn(queryable, []) -> {1, nil} end] do
      assert TenantedRepo.delete_all(scoped_note_query()) == {1, nil}
    end
    with_mock Ecto.TestRepo, [delete_all: fn(Note, [prefix: "tenant_test"]) -> {1, nil} end] do
      assert TenantedRepo.delete_all(Note, [prefix: "test"]) == {1, nil}
    end

    with_mock Ecto.TestRepo, [delete_all: fn(Note, []) -> {1, nil} end] do
      assert UntenantedRepo.delete_all(Note) == {1, nil}
    end


    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.delete_all(Note)
    end
    with_mock Ecto.TestRepo, [delete_all: fn(Tag, []) -> {1, nil} end] do
      assert ProcessTenantedRepo.delete_all(Tag)
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [delete_all: fn(Note, [prefix: "tenant_test"]) -> {1, nil} end] do
      assert ProcessTenantedRepo.delete_all(Note)
    end
  end

  test ".insert(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert(Note.changeset(%Note{}, %{}))
    end
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert(%Note{})
    end


    with_mock Ecto.TestRepo, [insert: fn(note, []) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert(scoped_note())
    end

    with_mock Ecto.TestRepo, [insert: fn(%Ecto.Changeset{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert(Note.changeset(scoped_note(), %{}))
    end

    with_mock Ecto.TestRepo, [insert: fn(%Note{}, [prefix: "tenant_test"]) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert(%Note{}, [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [insert: fn(%Note{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = UntenantedRepo.insert(%Note{})
    end


    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.insert(%Note{})
    end
    with_mock Ecto.TestRepo, [insert: fn(%Tag{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = ProcessTenantedRepo.insert(%Tag{})
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [insert: fn(%Note{}, [prefix: "tenant_test"]) -> {:ok, nil} end] do
      assert {:ok, _} = ProcessTenantedRepo.insert(%Note{})
    end
  end

  test ".update(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    with_mock Ecto.TestRepo, [update: fn(scoped_changeset, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = TenantedRepo.update(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [update: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _schema} = TenantedRepo.update(Note.changeset(%Note{id: 1}, %{body: "body"}), [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [update: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = UntenantedRepo.update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
    with_mock Ecto.TestRepo, [update: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = ProcessTenantedRepo.update(Tag.changeset(%Tag{id: 1}, %{name: "name"}))
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [update: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _schema} = ProcessTenantedRepo.update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
  end

  test ".insert_or_update(changeset, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert_or_update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    with_mock Ecto.TestRepo, [insert_or_update: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.insert_or_update(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [insert_or_update: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.insert_or_update(Note.changeset(%Note{id: 1}, %{body: "body"}), [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [insert_or_update: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = UntenantedRepo.insert_or_update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end


    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.insert_or_update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
    with_mock Ecto.TestRepo, [insert_or_update: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.insert_or_update(Tag.changeset(%Tag{id: 1}, %{name: "name"}))
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [insert_or_update: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.insert_or_update(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
  end

  test ".delete(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.delete(%Note{id: 1})
    end
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.delete(Note.changeset(%Note{id: 1}, %{}))
    end

    with_mock Ecto.TestRepo, [delete: fn(note, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete(scoped_note())
    end
    with_mock Ecto.TestRepo, [delete: fn(note, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [delete: fn(note, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete(%Note{id: 1}, [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [delete: fn(%Note{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = UntenantedRepo.delete(%Note{id: 1})
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.delete(%Note{id: 1})
    end
    with_mock Ecto.TestRepo, [delete: fn(%Tag{}, []) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.delete(%Tag{id: 1})
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [delete: fn(note, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.delete(%Note{id: 1})
    end
  end

  test ".insert!(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert!(Note.changeset(%Note{}, %{}))
    end
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert!(%Note{})
    end


    with_mock Ecto.TestRepo, [insert!: fn(note, []) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert!(scoped_note())
    end

    with_mock Ecto.TestRepo, [insert!: fn(%Ecto.Changeset{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert!(Note.changeset(scoped_note(), %{}))
    end

    with_mock Ecto.TestRepo, [insert!: fn(%Note{}, [prefix: "tenant_test"]) -> {:ok, nil} end] do
      assert {:ok, _} = TenantedRepo.insert!(%Note{}, [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [insert!: fn(%Note{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = UntenantedRepo.insert!(%Note{})
    end


    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.insert!(%Note{})
    end
    with_mock Ecto.TestRepo, [insert!: fn(%Tag{}, []) -> {:ok, nil} end] do
      assert {:ok, _} = ProcessTenantedRepo.insert!(%Tag{})
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [insert!: fn(%Note{}, [prefix: "tenant_test"]) -> {:ok, nil} end] do
      assert {:ok, _} = ProcessTenantedRepo.insert!(%Note{})
    end
  end

  test ".update!(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    with_mock Ecto.TestRepo, [update!: fn(scoped_changeset, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = TenantedRepo.update!(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [update!: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _schema} = TenantedRepo.update!(Note.changeset(%Note{id: 1}, %{body: "body"}), [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [update!: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = UntenantedRepo.update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
    with_mock Ecto.TestRepo, [update!: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _schema} = ProcessTenantedRepo.update!(Tag.changeset(%Tag{id: 1}, %{name: "name"}))
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [update!: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _schema} = ProcessTenantedRepo.update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
  end

  test ".insert_or_update!(changeset, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.insert_or_update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end

    with_mock Ecto.TestRepo, [insert_or_update!: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.insert_or_update!(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [insert_or_update!: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.insert_or_update!(Note.changeset(%Note{id: 1}, %{body: "body"}), [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [insert_or_update!: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = UntenantedRepo.insert_or_update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end


    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.insert_or_update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
    with_mock Ecto.TestRepo, [insert_or_update!: fn(%Ecto.Changeset{}, []) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.insert_or_update!(Tag.changeset(%Tag{id: 1}, %{name: "name"}))
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [insert_or_update!: fn(%Ecto.Changeset{}, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.insert_or_update!(Note.changeset(%Note{id: 1}, %{body: "body"}))
    end
  end

  test ".delete!(struct, opts \\ []) verifies tenant existence" do
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.delete!(%Note{id: 1})
    end
    assert_raise TenantMissingError, @error_message, fn ->
      TenantedRepo.delete!(Note.changeset(%Note{id: 1}, %{}))
    end

    with_mock Ecto.TestRepo, [delete!: fn(note, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete!(scoped_note())
    end
    with_mock Ecto.TestRepo, [delete!: fn(note, []) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete!(scoped_changeset())
    end
    with_mock Ecto.TestRepo, [delete!: fn(note, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert {:ok, _} = TenantedRepo.delete!(%Note{id: 1}, [prefix: "test"])
    end

    with_mock Ecto.TestRepo, [delete!: fn(%Note{}, []) -> {:ok, %{}} end] do
      assert {:ok, _} = UntenantedRepo.delete!(%Note{id: 1})
    end

    assert_raise TenantMissingError, @error_message, fn ->
      ProcessTenantedRepo.delete!(%Note{id: 1})
    end
    with_mock Ecto.TestRepo, [delete!: fn(%Tag{}, []) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.delete!(%Tag{id: 1})
    end
    Process.put(@prefix, "test")
    with_mock Ecto.TestRepo, [delete!: fn(note, [prefix: "tenant_test"]) -> {:ok, %{}} end] do
      assert ProcessTenantedRepo.delete!(%Note{id: 1})
    end
  end
end
