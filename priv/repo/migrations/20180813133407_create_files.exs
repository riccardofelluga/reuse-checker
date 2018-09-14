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

defmodule Reuse.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string, size: 65000
      add :has_copyright, :boolean, default: false, null: false
      add :spdx_license_expression, :string, size: 65000
      add :license_found_in_file, :boolean, default: false, null: false
      add :license_found_in_dot_license, :boolean, default: false, null: false
      add :license_found_in_debian_format, :boolean, default: false, null: false
      add :license_found_in_dot_spdx, :boolean, default: false, null: false
      add :spdx_license_expression_is_valid, :boolean, default: false, null: false
      add :license_header_in_case_of_copyright_error, :text
      add :todo_id, references(:todos, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:files, [:todo_id])
  end
end
