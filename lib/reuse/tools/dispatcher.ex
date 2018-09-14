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

defmodule Tools.Dispatcher do
  use GenServer

  def start_link(name, producer) do
    GenServer.start_link(__MODULE__, producer, name: name)
  end

  def get_next_work(name, work_id) do
    GenServer.call(name, {:get_next_work, work_id}, :infinity)
  end

  def shutdown(name) do
    GenServer.cast(name, {:shutdown})
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:get_next_work, work_id}, _from, producer) when is_function(producer) do
    task = producer.(work_id)
    {:reply, task, producer}
  end

  @impl true
  def handle_call({:get_next_work, _work_id}, _from, _producer) do
    raise("Producer must be a function.")
  end

  @impl true
  def handle_cast({:shutdown}, _producer) do
    {:noreply, fn -> :no_work end}
  end
end
