#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

defmodule Reuse.Repo.Migrations.IndexTodo do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :index, :integer
    end 

    create index(:repositories, [:todo_id], unique: true)
    create index(:todos, [:url], unique: true)
    create index(:todos, [:index], unique: true)
  end
end
