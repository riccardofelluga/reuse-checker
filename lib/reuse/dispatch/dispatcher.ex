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

defmodule Reuse.Dispatch.Dispatcher do
  require Logger

  alias Reuse.Db
  alias Reuse.Todo
  alias Reuse.Parse.ParseRepository

  @number_of_workers 10

  def run() do
    ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
      command: :begin_study
    })

    everything_done = fn ->
      ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
        command: :end_study
      })
    end

    producer = fn _work_id ->
      if Db.count_remaining() != 0 do
        %Todo{id: todo_id, url: repository_url} = Db.get_next_todo()
        Db.update_todo(todo_id, %{started: true})
        Db.insert_default_repo(todo_id)

        ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
          command: :add_repository,
          todo_id: todo_id,
          repository_url: repository_url
        })

        fn ->
          Logger.info("Start analyzing #{repository_url}.")
          ParseRepository.analyze_repository(repository_url, todo_id)
          Logger.info("Finished analyzing #{repository_url}.")

          {workload, done} = Db.get_todos_stats()
          remaining = workload - done

          ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
            command: :progress,
            remaining: remaining,
            progress: done * 100 / workload
          })
        end
      else
        :no_work
      end
    end

    machine_id = Application.get_env(:reuse, :machine_id)
    Tools.Workers.work(:dispatcher, @number_of_workers, machine_id, producer, everything_done)
  end

  def abort() do
    Tools.Workers.abort(:dispatcher)
  end
end
