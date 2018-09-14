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

defmodule Reuse.Parse.CheckDebian do
  alias Reuse.Parse.CheckFile

  @moduledoc """
  A checker which gets all the single file licences out of the debian/copyright file
  """

  @doc """
  Hello world.

  ## Examples

      iex> CheckDebian.check("debian/copyright")
      [
        %{has_copyright: true, license_found_in_debian_format: true, license_found_in_dot_license: false, license_found_in_dot_spdx: false, license_found_in_file: false, license_header_in_case_of_copyright_error: nil, spdx_license_expression: "CC-BY-SA-4.0", spdx_license_expression_is_valid: true, todo_id: nil, url: "README.md"},
      %{has_copyright: true, license_found_in_debian_format: true, license_found_in_dot_license: false, license_found_in_dot_spdx: false, license_found_in_file: false, license_header_in_case_of_copyright_error: nil, spdx_license_expression: "CC-BY-SA-4.0", spdx_license_expression_is_valid: true, todo_id: nil, url: "CHANGELOG.md"}
      ]
  """

  def check(todo_id) do
    case File.open("repos/" <> todo_id <> "/debian/copyright") do
      {:ok, lines} ->
        lines =
          IO.read(lines, :all)
          |> String.split("\n")

        read_file().({lines, [], [], todo_id})

      {_, error} ->
        {:error, "#{:file.format_error(error)}"}
    end
  end

  defp read_file do
    fn
      {[], _, result_list, _todo_id} ->
        result_list

      {[h | t], [], result_list, todo_id} ->
        if Regex.match?(~r/^Files:/i, h) do
          file = Regex.replace(~r/Files:[ \t]*/i, h, "")

          if Regex.match?(~r/\*/, file) do
            files =
              Regex.replace(~r/\*/, "repos/#{todo_id}/#{file}", "**")
              |> Path.wildcard(match_dot: true)

            read_file().({t, files, result_list, todo_id})
          else
            files =
              String.trim(file)
              |> String.split(" ")
              |> Enum.map(fn file -> "repos/#{todo_id}/#{file}" end)

            read_file().({t, files, result_list, todo_id})
          end
        else
          read_file().({t, [], result_list, todo_id})
        end

      {lines, current_files, result_list, todo_id} ->
        {tail_left, results} =
          extract_copyright_and_license_information(
            lines,
            current_files,
            false,
            nil,
            false,
            todo_id
          )

        read_file().({tail_left, [], result_list ++ results, todo_id})
    end
  end

  defp extract_copyright_and_license_information(
         list,
         current_files,
         copy,
         spdx,
         is_valid,
         todo_id
       ) do
    if (copy && spdx != nil) || Enum.empty?(list) do
      result_list =
        Enum.reduce(current_files, [], fn file, acc ->
          [
            %{
              url: "#{file}",
              has_copyright: copy,
              spdx_license_expression: spdx,
              license_found_in_debian_format: true,
              spdx_license_expression_is_valid: is_valid,
              todo_id: todo_id,
              started: true,
              completed: true
            }
            | acc
          ]
        end)

      {list, result_list}
    else
      [h | t] = list

      cond do
        Regex.match?(~r/Copyright:/i, h) ->
          extract_copyright_and_license_information(
            t,
            current_files,
            true,
            spdx,
            is_valid,
            todo_id
          )

        Regex.match?(~r/Licen[cs]e:/i, h) ->
          trim =
            Regex.replace(~r/Licen[cs]e:[ \t]+/i, h, "")
            |> String.trim()

          is_valid = CheckFile.spdx_expression_is_valid(trim)

          extract_copyright_and_license_information(
            t,
            current_files,
            copy,
            trim,
            is_valid,
            todo_id
          )

        Regex.match?(~r/Files:/i, h) ->
          result_list =
            Enum.reduce(current_files, [], fn file, acc ->
              [
                %{
                  url: "#{file}",
                  has_copyright: copy,
                  spdx_license_expression: spdx,
                  license_found_in_debian_format: true,
                  spdx_license_expression_is_valid: is_valid,
                  todo_id: todo_id,
                  started: true,
                  completed: true
                }
                | acc
              ]
            end)

          {list, result_list}

        true ->
          extract_copyright_and_license_information(
            t,
            current_files,
            copy,
            spdx,
            is_valid,
            todo_id
          )
      end
    end
  end
end
