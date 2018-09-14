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

defmodule Reuse.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "repositories" do
    field(:readme_exists, :boolean, default: false)
    field(:single_license_file_exists, :boolean, default: false)
    field(:spdx_license_file_exists, :boolean, default: false)
    field(:all_used_licenses_are_present_in_license_folder, :boolean, default: false)
    field(:authors_file_exists, :boolean, default: false)
    field(:license_folder_exists, :boolean, default: false)
    field(:debian_license_folder_exists, :boolean, default: false)
    field(:error, :boolean, default: false)
    field(:todo_id, :binary_id)

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [
      :readme_exists,
      :single_license_file_exists,
      :spdx_license_file_exists,
      :license_folder_exists,
      :debian_license_folder_exists,
      :all_used_licenses_are_present_in_license_folder,
      :authors_file_exists,
      :error,
      :todo_id
    ])
  end
end
