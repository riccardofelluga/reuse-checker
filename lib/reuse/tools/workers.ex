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

defmodule Tools.Workers do
  def work(dispatcher_name, number_of_workers, work_id, producer, everything_done)
      when is_function(everything_done) do
    {:ok, _pid} = Tools.Dispatcher.start_link(dispatcher_name, producer)

    try do
      Enum.to_list(1..number_of_workers)
      |> Enum.map(fn _x ->
        Task.async(fn ->
          Tools.Worker.work(
            work_id,
            fn -> Tools.Dispatcher.get_next_work(dispatcher_name, work_id) end,
            fn -> :done end
          )
        end)
      end)
      |> Task.yield_many(:infinity)

      everything_done.()
    after
      GenServer.stop(dispatcher_name)
    end
  end

  def work(_dispatcher_name, _number_of_workers, _work_id, _producer, _everything_done) do
    raise("everything_done must be a function.")
  end

  def abort(dispatcher_name) do
    GenServer.stop(dispatcher_name)
  end
end
