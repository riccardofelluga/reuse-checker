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

defmodule Reuse.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field(:url, :string)
    field(:started, :boolean, default: false)
    field(:completed, :boolean, default: false)
    field(:does_not_exist_anymore, :boolean, default: false)
    field(:assigned_to_machine, :integer)
    field(:study, :integer)

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [
      :id,
      :url,
      :started,
      :completed,
      :does_not_exist_anymore,
      :assigned_to_machine,
      :study
    ])
    |> validate_required([
      :url,
      :assigned_to_machine
    ])
  end
end
