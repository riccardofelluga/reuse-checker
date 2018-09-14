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

defmodule ReuseWeb.PageController do
  use ReuseWeb, :controller

  alias Reuse.Db
  alias Reuse.Repo
  alias Reuse.Todo
  alias Reuse.Dispatch.Dispatcher

  def index(conn, _params) do
    render(conn, "index.html")
  end

  defp validate_uri(str) do
    uri = URI.parse(str)

    case uri do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      %URI{path: nil} -> {:error, uri}
      uri -> {:ok, uri}
    end
  end

  def analyzing(conn, %{"url" => url}) do
    case validate_uri(url) do
      {:ok, _} ->
        todo_id = Db.insert_todo(url)
        Db.update_todo(todo_id, %{started: true})
        Db.add_to_repositories(todo_id)

        Task.start(fn ->
          try do
            Reuse.Parse.ParseRepository.analyze_repository(url, todo_id)

            ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
              command: :end_study,
              todo_id: todo_id
            })
          after
            Db.delete_by_id(todo_id)
          end
        end)

        render(conn, "analyzing.html", repository: url)

      {:error, _} ->
        conn
        |> put_flash(
          :input_error,
          "The URL #{url} does not seem to be correct. Please verify your input and try again."
        )
        |> render("index.html", repository: url)
    end
  end

  def check(conn, %{"todo_id" => todo_id}) do
    %{url: repo_url} =
      Repo.get_by(Todo, id: todo_id)
      |> Map.from_struct()

    tests = Reuse.Analyzer.get_tests_results(todo_id)

    render(conn, "check.html", repository: repo_url, tests: tests)
  end

  def dispatch(conn, _params) do
    Dispatcher.run()

    conn
    |> send_resp(200, "OK")
  end

  def abort(conn, _params) do
    Dispatcher.abort()

    conn
    |> send_resp(200, "OK")
  end

  def clean(conn, _params) do
    values_after_clean = Db.clean()

    conn
    |> render("data.json", data: values_after_clean)
  end

  def clean_unfinished(conn, _params) do
    values_after_clean = Db.clean_unfinished()

    conn
    |> render("data.json", data: values_after_clean)
  end

  def study(conn, _params) do
    workload = Db.count_remaining()

    render(conn, "study.html", workload: workload)
  end

  def results(conn, %{"study" => study}) do
    results = Reuse.Analyzer.get_results(study)

    render(conn, "results.html", results: results)
  end

  def contacts(conn, _params) do
    render(conn, "contacts.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
