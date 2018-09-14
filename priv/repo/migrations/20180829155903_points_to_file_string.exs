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

defmodule Reuse.Repo.Migrations.PointsToFileString do
  use Ecto.Migration

  def change do
    alter table(:files) do
      remove(:license_header_points_to_file)
    end

    alter table(:files) do
      add(:license_header_points_to_file, :string, size: 65000)
    end
  end
end
