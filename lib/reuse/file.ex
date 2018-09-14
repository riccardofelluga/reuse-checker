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

defmodule Reuse.File do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "files" do
    field(:has_copyright, :boolean, default: false)
    field(:license_found_in_debian_format, :boolean, default: false)
    field(:license_found_in_dot_license, :boolean, default: false)
    field(:license_found_in_dot_spdx, :boolean, default: false)
    field(:license_found_in_file, :boolean, default: false)
    field(:license_header_in_case_of_copyright_error, :string)
    field(:spdx_license_expression, :string)
    field(:spdx_license_expression_is_valid, :boolean, default: false)
    field(:license_header_points_to_file, :string)
    field(:url, :string)
    field(:todo_id, :binary_id)
    field(:started, :boolean, default: false)
    field(:completed, :boolean, default: false)
    field(:error, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [
      :url,
      :has_copyright,
      :spdx_license_expression,
      :license_found_in_file,
      :license_found_in_dot_license,
      :license_found_in_debian_format,
      :license_found_in_dot_spdx,
      :spdx_license_expression_is_valid,
      :license_header_points_to_file,
      :license_header_in_case_of_copyright_error,
      :todo_id,
      :started,
      :completed,
      :error
    ])
    |> validate_required([
      :url,
      :todo_id
    ])
  end
end
