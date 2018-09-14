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

defmodule Reuse.Parse.ParseRepository do
  require Logger

  alias Reuse.Parse.CheckDebian
  alias Reuse.Parse.CheckSpdx
  alias Reuse.Parse.CheckFile
  alias Reuse.Db

  @readme_regex ~r{^([^/]*)/([^/]*)/README([\.][^/]|[\.]|$)}
  @single_license_regex ~r{^([^/]*)/([^/]*)/LICEN[CS]E([\.][^/]|[\.]|$)|^([^/]*)/([^/]*)/COPYING([\.][^/]|[\.]|$)|^([^/]*)/([^/]*)/COPYRIGHT([\.][^/]|[\.]|$)}
  @spdx_regex ~r{^([^/]*)/([^/]*)/LICENSE\.spdx}
  @authors_regex ~r{^([^/]*)/([^/]*)/AUTHORS([\.][^/]|[\.]|$)|^([^/]*)/([^/]*)/CONTRIBUTORS([\.][^/]|[\.]|$)|^([^/]*)/([^/]*)/MAINTAINERS([\.][^/]|[\.]|$)}
  @number_of_workers 1000

  def analyze_repository(repository_url, todo_id) do
    Logger.info("Start analyzing #{repository_url}.")

    repository_dir = "repos/#{todo_id}"

    try do
      clone(repository_url, todo_id)
      Logger.info("Finished downloading #{repository_url} to #{repository_dir}.")
    rescue
      _ ->
        Logger.info("Repository #{repository_url} COULD NOT be downloaded.")
        File.rm_rf!(repository_dir)
    end

    if File.exists?(repository_dir) do
      ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
        command: :downloaded_repository,
        todo_id: todo_id
      })

      file_to_open =
        if File.exists?("repos/#{todo_id}/LICENSE.spdx"),
          do: "repos/#{todo_id}/LICENSE.spdx",
          else: "repos/#{todo_id}/LICENCE.spdx"

      repository_dir
      |> ls_dir!(todo_id, [".gitignore", ".git"])
      |> base_checks(todo_id)
      |> store_license_folder(todo_id)
      |> check_dir(todo_id, "repos/#{todo_id}/debian/copyright", fn todo_id ->
        set_true_repository_attribute(todo_id, :debian_license_folder_exists)
        CheckDebian.check(todo_id)
      end)
      |> check_dir(todo_id, file_to_open, fn todo_id ->
        set_true_repository_attribute(todo_id, :spdx_license_file_exists)

        CheckSpdx.check(todo_id)
        |> Enum.map(fn item ->
          {_, sub_dir} = String.split_at(item.url, 2)
          dir = "repos/#{todo_id}/#{sub_dir}"
          Map.replace!(item, :url, dir)
        end)
      end)
      |> check_license_suffix()
      |> check_remaining_files(todo_id)
    else
      set_true_todo_attribute(todo_id, :does_not_exist_anymore)
      set_true_todo_attribute(todo_id, :completed)

      ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
        command: :remove_repository,
        todo_id: todo_id
      })
    end
  end

  defp clone(url, todo_id) do
    unless File.dir?("repos"), do: File.mkdir("repos")

    if File.exists?("repos/#{todo_id}") do
      File.rm_rf!("repos/#{todo_id}")
    end

    System.cmd("git", ["clone", "--depth", "1", url, todo_id],
      stderr_to_stdout: true,
      cd: "repos"
    )
  end

  def ls_dir!(repository_dir, todo_id, ignore) do
    File.ls!(repository_dir)
    |> Enum.reduce([], fn file, out ->
      if String.ends_with?(file, ignore) do
        out
      else
        if File.dir?("#{repository_dir}/#{file}") do
          out ++ ls_dir!("#{repository_dir}/#{file}", todo_id, ignore)
        else
          out ++ [%{id: Ecto.UUID.generate(), url: "#{repository_dir}/#{file}", todo_id: todo_id}]
        end
      end
    end)
  end

  defp remaining(main_file_list, to_skip_list) do
    urls_to_skip = Enum.map(to_skip_list, fn %{url: url} -> url end)
    # IO.inspect(urls_to_skip)
    Enum.reject(main_file_list, fn file -> file.url in urls_to_skip end)
  end

  defp base_checks(file_list, todo_id) do
    Enum.flat_map(
      file_list,
      fn file ->
        cond do
          file.url =~ @spdx_regex ->
            [file]

          file.url =~ @readme_regex ->
            set_true_repository_attribute(file.todo_id, :readme_exists)
            [file]

          file.url =~ @single_license_regex ->
            set_true_repository_attribute(file.todo_id, :single_license_file_exists)
            store_license_file(todo_id, file.url)
            []

          file.url =~ @authors_regex ->
            set_true_repository_attribute(file.todo_id, :authors_file_exists)
            [file]

          true ->
            [file]
        end
      end
    )
  end

  defp check_dir(file_list, todo_id, directory, check_fn) do
    if File.exists?(directory) do
      files_found_in_license =
        check_fn.(todo_id)
        |> Enum.flat_map(fn item ->
          case Enum.find(file_list, fn file -> file.url == item.url end) do
            nil ->
              []

            file ->
              [Map.put(item, :id, file.id)]
          end
        end)

      Db.insert_files(files_found_in_license)

      file_at_directory = %{
        id: Enum.find(file_list, fn file -> file.url == directory end),
        url: directory
      }

      remaining(file_list, files_found_in_license ++ [file_at_directory])
    else
      file_list
    end
  end

  def store_license_folder(file_list, todo_id) do
    Logger.info("Checking license folder of #{todo_id}.")

    file_to_open =
      if File.exists?("repos/#{todo_id}/LICENCES"),
        do: "repos/#{todo_id}/LICENCES",
        else: "repos/#{todo_id}/LICENSES"

    if File.exists?(file_to_open) do
      set_true_repository_attribute(todo_id, :license_folder_exists)

      File.ls!(file_to_open)
      |> Enum.each(fn file_name ->
        store_license_file(todo_id, file_to_open, file_name)
      end)

      remaining(
        file_list,
        Enum.filter(file_list, fn file ->
          String.contains?(file.url, file_to_open)
        end)
      )
    else
      file_list
    end
  end

  defp store_license_file(todo_id, file_to_open, file_name \\ "") do
    license_file_path = if file_name == "", do: file_to_open, else: "#{file_to_open}/#{file_name}"

    contents = File.read!(license_file_path)

    case Regex.scan(~r{Valid-License-Identifier: ([a-zA-Z0-9_.+\-]*)}im, contents,
           capture: :all_but_first
         ) do
      [] ->
        case Regex.run(~r{(.*)\.[^.]+$}, file_name, capture: :all_but_first) do
          nil ->
            :no_license

          matches ->
            matches
            |> Enum.at(0)
            |> (&[%{license: &1, todo_id: todo_id}]).()
            |> Db.insert_licenses()
        end

      matches ->
        Enum.map(matches, fn [license] -> %{license: license, todo_id: todo_id} end)
        |> Db.insert_licenses()
    end
  end

  defp check_single_license(todo_id) do
    licenses_found_in_folder = Db.get_licenses_found_in_folder(todo_id)

    Db.get_all_licenses_from_files(todo_id)
    |> Enum.filter(fn license_name -> license_name not in licenses_found_in_folder end)
    |> Enum.empty?()
  end

  defp check_license_suffix(file_list) do
    Enum.filter(file_list, fn file ->
      not String.ends_with?(file.url, ".license") and not String.ends_with?(file.url, ".licence")
    end)
  end

  defp check_remaining_files(file_list, todo_id) do
    Db.insert_files(file_list)

    everything_done = fn ->
      cond do
        Db.get_repository_attribute(todo_id, :license_folder_exists) ->
          Db.update_repository(todo_id, %{
            all_used_licenses_are_present_in_license_folder: check_licenses_in_folder(todo_id)
          })

        Db.get_repository_attribute(todo_id, :single_license_file_exists) ->
          Db.update_repository(todo_id, %{
            all_used_licenses_are_present_in_license_folder: check_single_license(todo_id)
          })

        true ->
          :not_all_licenses
      end

      try do
        Task.start(fn ->
          ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
            command: :remove_repository_triggered,
            todo_id: todo_id
          })

          File.rm_rf!("repos/#{todo_id}")
        end)

        set_true_todo_attribute(todo_id, :completed)
      after
        ReuseWeb.Endpoint.broadcast("update:progress", "update_message", %{
          command: :remove_repository,
          todo_id: todo_id
        })
      end
    end

    producer = fn todo_id ->
      next_file = Db.get_next_file(todo_id)

      if is_nil(next_file) do
        :no_work
      else
        Db.update_file(next_file, %{started: true})

        fn ->
          {base_file, changes} = CheckFile.check(next_file)
          Db.update_file(base_file, changes)
        end
      end
    end

    Tools.Workers.work(
      String.to_atom("parser_#{todo_id}"),
      @number_of_workers,
      todo_id,
      producer,
      everything_done
    )
  end

  def check_licenses_in_folder(todo_id) do
    license_files_to_which_files_point = Db.get_all_license_files_to_which_files_point(todo_id)

    all_referenced_files_exist =
      license_files_to_which_files_point
      |> Enum.map(fn file ->
        File.exists?("repos/#{todo_id}/#{file}")
      end)
      |> Enum.filter(fn exists -> exists == false end)
      |> Enum.empty?()

    license_folder_licenses =
      Db.get_licenses_found_in_folder(todo_id)
      |> Enum.map(fn x -> String.downcase(x) end)

    licenses_from_files = Db.get_all_licenses_from_files(todo_id)

    licenses_mentioned_and_not_referenced_in_files_exist =
      if Enum.empty?(licenses_from_files) do
        true
      else
        Enum.flat_map(licenses_from_files, fn spdx_license_expression ->
          String.replace(spdx_license_expression, "(", "")
          |> String.replace(")", "")
          |> String.downcase()
          |> String.split([" and ", " or ", " with "], trim: true)
        end)
        |> Enum.filter(fn license -> license != nil end)
        |> Enum.map(fn license -> String.replace_trailing(license, "-or-later", "+") end)
        |> Enum.filter(fn license ->
          case String.ends_with?(license, "+") do
            true ->
              base_license =
                license
                |> String.split("-")
                |> Enum.at(0)

              version =
                license
                |> String.split("-")
                |> Enum.at(1)

              license_found_with_equal_or_greater_version =
                license_folder_licenses
                |> Enum.filter(fn license -> license != nil end)
                |> Enum.any?(fn found_license ->
                  case String.contains?(found_license, "-") do
                    false ->
                      true

                    true ->
                      base_found_license =
                        found_license
                        |> String.split("-")
                        |> Enum.at(0)

                      found_version =
                        found_license
                        |> String.split("-")
                        |> Enum.at(1)

                      base_license == base_found_license and
                        version_is_equal_or_later(version, found_version)
                  end
                end)

              not license_found_with_equal_or_greater_version

            false ->
              license not in license_folder_licenses
          end
        end)
        |> Enum.empty?()
      end

    all_referenced_files_exist and licenses_mentioned_and_not_referenced_in_files_exist
  end

  def version_is_equal_or_later(version1, version2) do
    version1_has_major = String.contains?(version1, ".")
    version1_has_minor = version1_has_major

    version1_has_patch =
      String.split(version1, ".")
      |> Enum.count() >= 3

    version2_has_major = String.contains?(version2, ".")
    version2_has_minor = version2_has_major

    version2_has_patch =
      String.split(version2, ".")
      |> Enum.count() >= 3

    version1_parts = String.split(version1, ".")
    version2_parts = String.split(version1, ".")

    version1_major =
      case version1_has_major do
        true ->
          case Integer.parse(Enum.at(version1_parts, 0)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    version2_major =
      case version2_has_major do
        true ->
          case Integer.parse(Enum.at(version2_parts, 0)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    version1_minor =
      case version1_has_minor do
        true ->
          case Integer.parse(Enum.at(version1_parts, 1)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    version2_minor =
      case version2_has_minor do
        true ->
          case Integer.parse(Enum.at(version2_parts, 1)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    version1_patch =
      case version1_has_patch do
        true ->
          case Integer.parse(Enum.at(version1_parts, 2)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    version2_patch =
      case version2_has_patch do
        true ->
          case Integer.parse(Enum.at(version2_parts, 2)) do
            {value, ""} -> value
            _ -> 0
          end

        false ->
          0
      end

    (version1_major == version2_major and version1_minor == version2_minor and
       version1_patch == version2_patch) or
      (version1_major == version2_major and version1_minor == version2_minor and
         version1_patch < version2_patch) or
      (version1_major == version2_major and version1_minor < version2_minor) or
      version1_major < version2_major
  end

  defp set_true_repository_attribute(todo_id, attr) do
    Db.update_repository(todo_id, %{attr => true})
  end

  defp set_true_todo_attribute(todo_id, attr) do
    Db.update_todo(todo_id, %{attr => true})
  end
end
