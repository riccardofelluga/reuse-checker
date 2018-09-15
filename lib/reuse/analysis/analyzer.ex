#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

defmodule Reuse.Analyzer do
  import Ecto.Query, warn: false

  alias Reuse.Repo
  alias Reuse.Repository
  alias Reuse.File
  alias Reuse.Todo

  def get_results(study) do
    number_of_repositories =
      from(t in Todo, where: t.study == ^study)
      |> Repo.all()
      |> Enum.count()

    number_of_machines =
      from(t in Todo,
        where: t.study == ^study,
        group_by: t.assigned_to_machine,
        select: t.assigned_to_machine
      )
      |> Repo.all()
      |> Enum.count()

    number_of_repositories_analyzed =
      from(t in Todo, where: t.study == ^study, where: t.completed == true, select: t.id)
      |> Repo.aggregate(:count, :id)

    number_of_files_analyzed =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    does_not_exist_anymore =
      from(t in Todo,
        where: t.study == ^study,
        where: t.does_not_exist_anymore == true,
        select: t.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_readme_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.readme_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_single_license_file_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.single_license_file_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_spdx_license_file_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.spdx_license_file_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_license_folder_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.license_folder_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_debian_license_folder_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.debian_license_folder_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_all_used_licenses_are_present_in_license_folder =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.all_used_licenses_are_present_in_license_folder == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_authors_file_exists =
      from(r in Repository,
        join: t in Todo,
        where: t.id == r.todo_id,
        where: t.study == ^study,
        where: r.authors_file_exists == true,
        select: r.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_has_copyright =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.has_copyright == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_license_found_in_file =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.license_found_in_file == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_license_found_in_dot_license =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.license_found_in_dot_license == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_license_found_in_debian_format =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.license_found_in_debian_format == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_license_found_in_dot_spdx =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.license_found_in_dot_spdx == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_spdx_license_expression_is_valid =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and f.spdx_license_expression_is_valid == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    absolute_files_spdx_license_expression_exists =
      from(f in File,
        join: t in Todo,
        where: t.id == f.todo_id,
        where: t.study == ^study,
        where: f.completed == true and not is_nil(f.spdx_license_expression),
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    basis_repositories =
      case number_of_repositories_analyzed - does_not_exist_anymore do
        # Just avoid division by 0
        0 -> 1
        n -> n
      end

    basis_files =
      case number_of_files_analyzed do
        # Just avoid division by 0
        0 -> 1
        n -> n
      end

    %{
      number_of_repositories: number_of_repositories,
      number_of_machines: number_of_machines,
      number_of_repositories_analyzed: number_of_repositories_analyzed,
      number_of_files_analyzed: number_of_files_analyzed,
      does_not_exist_anymore: does_not_exist_anymore,
      basis_repositories: basis_repositories,
      absolute_readme_exists: absolute_readme_exists,
      absolute_single_license_file_exists: absolute_single_license_file_exists,
      absolute_spdx_license_file_exists: absolute_spdx_license_file_exists,
      absolute_license_folder_exists: absolute_license_folder_exists,
      absolute_all_used_licenses_are_present_in_license_folder:
        absolute_all_used_licenses_are_present_in_license_folder,
      absolute_authors_file_exists: absolute_authors_file_exists,
      absolute_files_has_copyright: absolute_files_has_copyright,
      absolute_files_license_found_in_file: absolute_files_license_found_in_file,
      absolute_files_license_found_in_dot_license: absolute_files_license_found_in_dot_license,
      absolute_files_license_found_in_debian_format:
        absolute_files_license_found_in_debian_format,
      absolute_files_license_found_in_dot_spdx: absolute_files_license_found_in_dot_spdx,
      absolute_files_spdx_license_expression_is_valid:
        absolute_files_spdx_license_expression_is_valid,
      absolute_files_spdx_license_expression_exists:
        absolute_files_spdx_license_expression_exists,
      absolute_debian_license_folder_exists: absolute_debian_license_folder_exists,
      relative_debian_license_folder_exists:
        Float.round(100 * absolute_debian_license_folder_exists / basis_repositories, 1),
      relative_readme_exists: Float.round(100 * absolute_readme_exists / basis_repositories, 1),
      relative_single_license_file_exists:
        Float.round(100 * absolute_single_license_file_exists / basis_repositories, 1),
      relative_spdx_license_file_exists:
        Float.round(100 * absolute_spdx_license_file_exists / basis_repositories, 1),
      relative_license_folder_exists:
        Float.round(100 * absolute_license_folder_exists / basis_repositories, 1),
      relative_all_used_licenses_are_present_in_license_folder:
        Float.round(
          100 * absolute_all_used_licenses_are_present_in_license_folder / basis_repositories,
          1
        ),
      relative_authors_file_exists:
        Float.round(100 * absolute_authors_file_exists / basis_repositories, 1),
      relative_files_has_copyright:
        Float.round(100 * absolute_files_has_copyright / basis_files, 1),
      relative_files_license_found_in_file:
        Float.round(100 * absolute_files_license_found_in_file / basis_files, 1),
      relative_files_license_found_in_dot_license:
        Float.round(100 * absolute_files_license_found_in_dot_license / basis_files, 1),
      relative_files_license_found_in_debian_format:
        Float.round(100 * absolute_files_license_found_in_debian_format / basis_files, 1),
      relative_files_license_found_in_dot_spdx:
        Float.round(100 * absolute_files_license_found_in_dot_spdx / basis_files, 1),
      relative_files_spdx_license_expression_is_valid:
        Float.round(100 * absolute_files_spdx_license_expression_is_valid / basis_files, 1),
      relative_files_spdx_license_expression_exists:
        Float.round(100 * absolute_files_spdx_license_expression_exists / basis_files, 1)
    }
  end

  def get_tests_results(todo_id) do
    # answer making queries

    number_of_files =
      from(f in File,
        where: f.todo_id == ^todo_id
      )
      |> Repo.aggregate(:count, :id)

    does_not_exist_anymore =
      from(t in Todo,
        where: t.id == ^todo_id,
        select: t.does_not_exist_anymore
      )
      |> Repo.one()

    readme_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.readme_exists
      )
      |> Repo.one()

    authors_file_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.authors_file_exists
      )
      |> Repo.one()

    single_license_file_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.single_license_file_exists
      )
      |> Repo.one()

    license_folder_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.license_folder_exists
      )
      |> Repo.one()

    all_used_licenses_are_present_in_license_folder =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.all_used_licenses_are_present_in_license_folder
      )
      |> Repo.one()

    spdx_license_file_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.spdx_license_file_exists
      )
      |> Repo.one()

    files_license_found_in_dot_spdx =
      from(f in File,
        where: f.todo_id == ^todo_id,
        where:
          f.completed == true and f.license_found_in_dot_spdx == true and
            f.spdx_license_expression_is_valid == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    debian_license_folder_exists =
      from(r in Repository,
        where: r.todo_id == ^todo_id,
        select: r.debian_license_folder_exists
      )
      |> Repo.one()

    files_license_found_in_debian_format =
      from(f in File,
        where: f.todo_id == ^todo_id,
        where:
          f.completed == true and f.license_found_in_debian_format == true and
            f.spdx_license_expression_is_valid == true,
        select: f.id
      )
      |> Repo.aggregate(:count, :id)

    has_copyright_count =
      from(f in File,
        where: f.todo_id == ^todo_id
      )
      |> Repo.aggregate(:count, :id)

    files_license_found_in_file =
      from(f in File,
        where: f.todo_id == ^todo_id,
        where:
          f.completed == true and f.license_found_in_file == true and
            f.spdx_license_expression_is_valid == true
      )
      |> Repo.aggregate(:count, :id)

    files_license_found_in_dot_license =
      from(f in File,
        where: f.todo_id == ^todo_id,
        where:
          f.completed == true and f.license_found_in_dot_license == true and
            f.spdx_license_expression_is_valid == true
      )
      |> Repo.aggregate(:count, :id)

    each_file_has_copyright_and_license =
      files_license_found_in_debian_format + files_license_found_in_dot_spdx +
        files_license_found_in_dot_license + files_license_found_in_file >= number_of_files and
        has_copyright_count >= number_of_files and number_of_files != 0

    %{
      compliant:
        each_file_has_copyright_and_license and all_used_licenses_are_present_in_license_folder,
      number_of_files: number_of_files,
      readme_exists: readme_exists,
      authors_file_exists: authors_file_exists,
      single_license_file_exists: single_license_file_exists,
      multiple_licenses: license_folder_exists,
      all_licenses_present: all_used_licenses_are_present_in_license_folder,
      each_file_has_copyright_and_license: each_file_has_copyright_and_license,
      inventory_of_software_included: spdx_license_file_exists,
      inventory_of_software_included_with_all_files:
        files_license_found_in_dot_spdx >= number_of_files and number_of_files != 0,
      debian_file_found: debian_license_folder_exists,
      debian_declared_files_count: files_license_found_in_debian_format,
      spdx_file_found: spdx_license_file_exists,
      spdx_declared_files_count: files_license_found_in_dot_spdx,
      copyright_count: has_copyright_count,
      license_in_file: files_license_found_in_file,
      license_in_dot_license: files_license_found_in_dot_license,
      does_not_exist: does_not_exist_anymore
    }
  end
end
