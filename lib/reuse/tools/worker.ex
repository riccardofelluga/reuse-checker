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

defmodule Tools.Worker do
  def work(work_id, get_next_work, done) when is_function(get_next_work) and is_function(done) do
    work = get_next_work.()
    do_the_work(work, get_next_work, work_id, done)
  end

  def work(_work_id, _get_next_work, _done) do
    raise("get_next_work and done must be a function.")
  end

  defp do_the_work(work, get_next_work, work_id, done)
       when is_function(get_next_work) and is_function(work) and is_function(done) and
              get_next_work != :no_work do
    task = Task.async(work)
    Task.await(task, :infinity)
    work(work_id, get_next_work, done)
  end

  defp do_the_work(_work, _get_next_work, _work_id, done) do
    done.()
  end
end
