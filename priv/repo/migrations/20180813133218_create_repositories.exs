#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

defmodule Reuse.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories, primary_key: false) do
      add :id, :binary_id, primary_key: true      
      add :readme_exists, :boolean, default: false, null: false
      add :single_license_file_exists, :boolean, default: false, null: false
      add :spdx_license_file_exists, :boolean, default: false, null: false
      add :license_folder_exists, :boolean, default: false, null: false
      add :all_used_licenses_are_present_in_license_folder, :boolean, default: false, null: false
      add :authors_file_exists, :boolean, default: false, null: false
      add :todo_id, references(:todos, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:repositories, [:todo_id])
  end
end
