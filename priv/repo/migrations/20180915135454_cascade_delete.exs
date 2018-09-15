#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

defmodule Reuse.Repo.Migrations.CascadeDelete do
  use Ecto.Migration

  def change do
    drop constraint(:files, "files_todo_id_fkey")
    alter table(:files) do
      modify :todo_id, references(:todos, on_delete: :delete_all, type: :binary_id)
    end

    drop constraint(:licenses, "licenses_todo_id_fkey")
    alter table(:licenses) do
      modify :todo_id, references(:todos, on_delete: :delete_all, type: :binary_id)
    end

    drop constraint(:repositories, "repositories_todo_id_fkey")
    alter table(:repositories) do
      modify :todo_id, references(:todos, on_delete: :delete_all, type: :binary_id)
    end
  end
end
