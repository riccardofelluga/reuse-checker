# 
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
# 

defmodule Reuse.Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:reuse)
    path = Application.app_dir(:reuse, "priv/repo/migrations")
    Ecto.Migrator.run(Reuse.Repo, path, :up, all: true)
  end
end
