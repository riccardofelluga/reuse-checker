# 
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
# 

defmodule Reuse.License do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "licenses" do
    field(:license, :string)
    field(:todo_id, :binary_id)

    timestamps()
  end

  @doc false
  def changeset(license, attrs) do
    license
    |> cast(attrs, [
      :license,
      :todo_id
    ])
    |> validate_required([
      :license,
      :todo_id
    ])
  end
end
