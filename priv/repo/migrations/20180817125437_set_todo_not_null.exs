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

defmodule Reuse.Repo.Migrations.SetTodoNotNull do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      remove :todo_id   
    end 
    
    alter table(:repositories) do
      add :todo_id, references(:todos, on_delete: :nothing, type: :binary_id), null: false    
    end 
  end
end
