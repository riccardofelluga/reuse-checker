# 
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, 
#                    Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, 
#                    Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
# 

defmodule Reuse.Db do
  import Ecto.Query, warn: false

  alias Reuse.Repo
  alias Reuse.Repository
  alias Reuse.File
  alias Reuse.Todo
  alias Reuse.License

  def get_next_todo() do
    [todo] = get_todos(1)
    todo
  end

  def get_todos(limit) do
    machine = Application.get_env(:reuse, :machine_id)

    query =
      from(
        r in Todo,
        where: r.assigned_to_machine == ^machine and r.started == false,
        limit: ^limit
      )

    Repo.all(query)
  end

  def get_next_file(todo_id) do
    query =
      from(
        f in File,
        where: f.todo_id == ^todo_id and f.started == false,
        limit: 1
      )

    Repo.one(query)
  end

  def get_todos_stats() do
    machine = Application.get_env(:reuse, :machine_id)

    done_query =
      from(t in Todo,
        distinct: t.id,
        where: t.assigned_to_machine == ^machine and t.completed == true,
        select: t.id
      )

    workload_query =
      from(t in Todo,
        distinct: t.id,
        where: t.assigned_to_machine == ^machine,
        select: t.id
      )

    query =
      from(w in subquery(workload_query),
        left_join: d in subquery(done_query),
        on: w.id == d.id,
        select: {count(w.id), count(d.id)}
      )

    Repo.one(query)
  end

  def insert_todo(url) do
    machine = Application.get_env(:reuse, :machine_id)

    case Repo.get_by(Todo, url: url) do
      nil ->
        %Todo{}
        |> Todo.changeset(%{assigned_to_machine: machine, url: url, study: 0})
        |> Repo.insert!()

        %{id: todo_id} =
          Repo.get_by(Todo, url: url)
          |> Map.from_struct()

        todo_id

      schema ->
        %{id: todo_id_from_db} = Map.from_struct(schema)

        clean_by_id(todo_id_from_db)

        todo_id_from_db
    end
  end

  def count_remaining() do
    machine = Application.get_env(:reuse, :machine_id)

    query =
      from(r in Todo,
        distinct: r.id,
        where: r.assigned_to_machine == ^machine and r.started == false
      )

    Repo.aggregate(query, :count, :id)
  end

  def count_workload() do
    machine = Application.get_env(:reuse, :machine_id)

    query =
      from(r in Todo,
        distinct: r.id,
        where: r.assigned_to_machine == ^machine
      )

    Repo.aggregate(query, :count, :id)
  end

  def count_done() do
    machine = Application.get_env(:reuse, :machine_id)

    query =
      from(r in Todo,
        distinct: r.id,
        where: r.assigned_to_machine == ^machine and r.started == true and r.completed == true
      )

    Repo.aggregate(query, :count, :id)
  end

  def update_todo(id, attrs) do
    Repo.get_by(Todo, id: id)
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def clean() do
    machine = Application.get_env(:reuse, :machine_id)

    query1 =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.assigned_to_machine == ^machine
      )

    query2 =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.assigned_to_machine == ^machine
      )

    query3 =
      from(t in Todo,
        where: t.assigned_to_machine == ^machine
      )

    query4 =
      from(l in License,
        join: t in Todo,
        where: t.id == l.todo_id,
        where: t.assigned_to_machine == ^machine
      )

    Repo.delete_all(query1)
    Repo.delete_all(query2)
    Repo.delete_all(query4)

    Repo.update_all(query3, set: [started: false, completed: false, does_not_exist_anymore: false])

    %{workload: count_remaining()}
  end

  def clean_unfinished() do
    machine = Application.get_env(:reuse, :machine_id)

    query1 =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.assigned_to_machine == ^machine,
        where: t.completed == false
      )

    query2 =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.assigned_to_machine == ^machine,
        where: t.completed == false
      )

    query3 =
      from(t in Todo,
        where: t.assigned_to_machine == ^machine,
        where: t.completed == false
      )

    query4 =
      from(l in License,
        join: t in Todo,
        where: t.id == l.todo_id,
        where: t.assigned_to_machine == ^machine,
        where: t.completed == false
      )

    Repo.delete_all(query1)
    Repo.delete_all(query2)
    Repo.delete_all(query4)

    Repo.update_all(query3, set: [started: false, does_not_exist_anymore: false])

    %{workload: count_remaining()}
  end

  def clean_by_id(todo_id) do
    query1 =
      from(f in File,
        where: f.todo_id == ^todo_id
      )

    query2 =
      from(r in Repository,
        where: r.todo_id == ^todo_id
      )

    query3 =
      from(t in Todo,
        where: t.id == ^todo_id
      )

    query4 =
      from(l in License,
        where: l.todo_id == ^todo_id
      )

    Repo.delete_all(query1)
    Repo.delete_all(query2)
    Repo.delete_all(query4)

    Repo.update_all(query3, set: [started: false, completed: false, does_not_exist_anymore: false])
  end

  ## REPOSITORY tools
  def insert_default_repo(todo_id) do
    %Repository{}
    |> Repository.changeset(%{todo_id: todo_id})
    |> Repo.insert!()
  end

  def update_repository(todo_id, attrs) do
    Repo.get_by(Repository, todo_id: todo_id)
    |> Repository.changeset(attrs)
    |> Repo.update()
  end

  def report_repository_result(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  ## FILE tools

  def update_file(base_file, changes) do
    File.changeset(base_file, changes)
    |> Repo.update()
  end

  def insert_files(file_list \\ []) do
    # Enum.chunk_every(file_list, 20_000)
    # |> Enum.each(fn chunk ->
    #   Ecto.Multi.new()
    #   |> Ecto.Multi.insert_all(:file, File, chunk)
    #   |> Repo.transaction()
    # end)
    Enum.each(file_list, fn file ->
      %File{}
      |> File.changeset(file)
      |> Repo.insert()
    end)
  end

  def get_all_licenses_from_files(todo_id) do
    query =
      from(f in File,
        distinct: f.spdx_license_expression,
        where: f.todo_id == ^todo_id,
        where: is_nil(f.license_header_points_to_file),
        select: f.spdx_license_expression
      )

    Repo.all(query)
    |> Enum.reject(fn item -> is_nil(item) end)
  end

  def get_all_license_files_to_which_files_point(todo_id) do
    query =
      from(f in File,
        distinct: f.license_header_points_to_file,
        where: f.todo_id == ^todo_id,
        where: not is_nil(f.license_header_points_to_file),
        select: f.license_header_points_to_file
      )

    Repo.all(query)
    |> Enum.reject(fn item -> is_nil(item) end)
  end

  def insert_licenses(licenses_spdx_expressions \\ [])

  def insert_licenses(licenses_spdx_expressions)
      when not is_nil(licenses_spdx_expressions) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:license, License, licenses_spdx_expressions)
    |> Repo.transaction()
  end

  def insert_licenses(_) do
  end

  def get_licenses_found_in_folder(todo_id) do
    query =
      from(l in License,
        distinct: l.license,
        where: l.todo_id == ^todo_id,
        select: l.license
      )

    Repo.all(query)
  end

  def get_repository_attribute(todo_id, attr) do
    Map.fetch!(Repo.get_by(Repository, todo_id: todo_id), attr)
  end
end
