# 
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
# 

defmodule Reuse.Parse.CheckFile do
  @moduledoc """
  A checker if a file contains Copyright, SPDX-License-Identifier
  in the header or otherwise in a .license-file with the same name

  """

  @doc """
  Hello world.

  ## Examples

      iex> ReuseFileCheck.check("example.py", 123)
      {:ok,
        %{
          has_copyright: true,
          license_found_in_debian_format: false,
          license_found_in_dot_license: false,
          license_found_in_dot_spdx: false,
          license_found_in_file: true,
          license_header_in_case_of_copyright_error: nil,
          spdx_license_expression: "GPL-3.0-or-later",
          spdx_license_expression_is_valid: true,
          todo_id: 123,
          url: "example.py"
        }}
  """

  require Logger

  @spdx_identifiers [
    "0bsd",
    "aal",
    "abstyles",
    "adobe-2006",
    "adobe-glyph",
    "adsl",
    "afl-1.1",
    "afl-1.2",
    "afl-2.0",
    "afl-2.1",
    "afl-3.0",
    "afmparse",
    "agpl-1.0",
    "agpl-3.0-only",
    "agpl-3.0-or-later",
    "agpl-3.0",
    "aladdin",
    "amdplpa",
    "aml",
    "ampas",
    "antlr-pd",
    "apache-1.0",
    "apache-1.1",
    "apache-2.0",
    "apafml",
    "apl-1.0",
    "apsl-1.0",
    "apsl-1.1",
    "apsl-1.2",
    "apsl-2.0",
    "artistic-1.0-cl8",
    "artistic-1.0-perl",
    "artistic-1.0",
    "artistic-2.0",
    "bahyph",
    "barr",
    "beerware",
    "bittorrent-1.0",
    "bittorrent-1.1",
    "borceux",
    "bsd-1-clause",
    "bsd-2-clause-freebsd",
    "bsd-2-clause-netbsd",
    "bsd-2-clause-patent",
    "bsd-2-clause",
    "bsd-3-clause-attribution",
    "bsd-3-clause-clear",
    "bsd-3-clause-lbnl",
    "bsd-3-clause-no-nuclear-license-2014",
    "bsd-3-clause-no-nuclear-license",
    "bsd-3-clause-no-nuclear-warranty",
    "bsd-3-clause",
    "bsd-4-clause-uc",
    "bsd-4-clause",
    "bsd-protection",
    "bsd-source-code",
    "bsl-1.0",
    "bzip2-1.0.5",
    "bzip2-1.0.6",
    "caldera",
    "catosl-1.1",
    "cc0-1.0",
    "cc-by-1.0",
    "cc-by-2.0",
    "cc-by-2.5",
    "cc-by-3.0",
    "cc-by-4.0",
    "cc-by-nc-1.0",
    "cc-by-nc-2.0",
    "cc-by-nc-2.5",
    "cc-by-nc-3.0",
    "cc-by-nc-4.0",
    "cc-by-nc-nd-1.0",
    "cc-by-nc-nd-2.0",
    "cc-by-nc-nd-2.5",
    "cc-by-nc-nd-3.0",
    "cc-by-nc-nd-4.0",
    "cc-by-nc-sa-1.0",
    "cc-by-nc-sa-2.0",
    "cc-by-nc-sa-2.5",
    "cc-by-nc-sa-3.0",
    "cc-by-nc-sa-4.0",
    "cc-by-nd-1.0",
    "cc-by-nd-2.0",
    "cc-by-nd-2.5",
    "cc-by-nd-3.0",
    "cc-by-nd-4.0",
    "cc-by-sa-1.0",
    "cc-by-sa-2.0",
    "cc-by-sa-2.5",
    "cc-by-sa-3.0",
    "cc-by-sa-4.0",
    "cddl-1.0",
    "cddl-1.1",
    "cdla-permissive-1.0",
    "cdla-sharing-1.0",
    "cecill-1.0",
    "cecill-1.1",
    "cecill-2.0",
    "cecill-2.1",
    "cecill-b",
    "cecill-c",
    "clartistic",
    "cnri-jython",
    "cnri-python-gpl-compatible",
    "cnri-python",
    "condor-1.1",
    "cpal-1.0",
    "cpl-1.0",
    "cpol-1.02",
    "crossword",
    "crystalstacker",
    "cua-opl-1.0",
    "cube",
    "curl",
    "d-fsl-1.0",
    "diffmark",
    "doc",
    "dotseqn",
    "dsdp",
    "dvipdfm",
    "ecl-1.0",
    "ecl-2.0",
    "ecos-2.0",
    "efl-1.0",
    "efl-2.0",
    "egenix",
    "entessa",
    "epl-1.0",
    "epl-2.0",
    "erlpl-1.1",
    "eudatagrid",
    "eupl-1.0",
    "eupl-1.1",
    "eupl-1.2",
    "eurosym",
    "fair",
    "frameworx-1.0",
    "freeimage",
    "fsfap",
    "fsfullr",
    "fsful",
    "ftl",
    "gfdl-1.1-only",
    "gfdl-1.1-or-later",
    "gfdl-1.1",
    "gfdl-1.2-only",
    "gfdl-1.2-or-later",
    "gfdl-1.2",
    "gfdl-1.3-only",
    "gfdl-1.3-or-later",
    "gfdl-1.3",
    "giftware",
    "gl2ps",
    "glide",
    "glulxe",
    "gnuplot",
    "gpl-1.0-only",
    "gpl-1.0-or-later",
    "gpl-1.0",
    "gpl-1.0+",
    "gpl-2.0-only",
    "gpl-2.0-or-later",
    "gpl-2.0-with-autoconf-exception",
    "gpl-2.0-with-bison-exception",
    "gpl-2.0-with-classpath-exception",
    "gpl-2.0-with-font-exception",
    "gpl-2.0-with-gcc-exception",
    "gpl-2.0",
    "gpl-2.0+",
    "gpl-3.0-only",
    "gpl-3.0-or-later",
    "gpl-3.0-with-autoconf-exception",
    "gpl-3.0-with-gcc-exception",
    "gpl-3.0",
    "gpl-3.0+",
    "gsoap-1.3b",
    "haskellreport",
    "hpnd",
    "ibm-pibs",
    "icu",
    "ijg",
    "imagemagick",
    "imatix",
    "imlib2",
    "info-zip",
    "intel-acpi",
    "intel",
    "interbase-1.0",
    "ipa",
    "ipl-1.0",
    "isc",
    "jasper-2.0",
    "json",
    "lal-1.2",
    "lal-1.3",
    "latex2e",
    "leptonica",
    "lgpl-2.0-only",
    "lgpl-2.0-or-later",
    "lgpl-2.0",
    "lgpl-2.0+",
    "lgpl-2.1-only",
    "lgpl-2.1-or-later",
    "lgpl-2.1",
    "lgpl-2.1+",
    "lgpl-3.0-only",
    "lgpl-3.0-or-later",
    "lgpl-3.0",
    "lgpl-3.0+",
    "lgpllr",
    "libpng",
    "libtiff",
    "liliq-p-1.1",
    "liliq-r-1.1",
    "liliq-rplus-1.1",
    "lpl-1.02",
    "lpl-1.0",
    "lppl-1.0",
    "lppl-1.1",
    "lppl-1.2",
    "lppl-1.3a",
    "lppl-1.3c",
    "makeindex",
    "miros",
    "mit-advertising",
    "mit-cmu",
    "mit-enna",
    "mit-feh",
    "mitnfa",
    "mit",
    "motosoto",
    "mpich2",
    "mpl-1.0",
    "mpl-1.1",
    "mpl-2.0-no-copyleft-exception",
    "mpl-2.0",
    "ms-pl",
    "ms-rl",
    "mtll",
    "multics",
    "mup",
    "nasa-1.3",
    "naumen",
    "nbpl-1.0",
    "ncsa",
    "netcdf",
    "net-snmp",
    "newsletr",
    "ngpl",
    "nlod-1.0",
    "nlpl",
    "nokia",
    "nosl",
    "noweb",
    "npl-1.0",
    "npl-1.1",
    "nposl-3.0",
    "nrl",
    "ntp",
    "nunit",
    "occt-pl",
    "oclc-2.0",
    "odbl-1.0",
    "ofl-1.0",
    "ofl-1.1",
    "ogtsl",
    "oldap-1.1",
    "oldap-1.2",
    "oldap-1.3",
    "oldap-1.4",
    "oldap-2.0.1",
    "oldap-2.0",
    "oldap-2.1",
    "oldap-2.2.1",
    "oldap-2.2.2",
    "oldap-2.2",
    "oldap-2.3",
    "oldap-2.4",
    "oldap-2.5",
    "oldap-2.6",
    "oldap-2.7",
    "oldap-2.8",
    "oml",
    "openssl",
    "opl-1.0",
    "oset-pl-2.1",
    "osl-1.0",
    "osl-1.1",
    "osl-2.0",
    "osl-2.1",
    "osl-3.0",
    "pddl-1.0",
    "php-3.01",
    "php-3.0",
    "plexus",
    "postgresql",
    "psfrag",
    "psutils",
    "python-2.0",
    "qhull",
    "qpl-1.0",
    "rdisc",
    "rhecos-1.1",
    "rpl-1.1",
    "rpl-1.5",
    "rpsl-1.0",
    "rsa-md",
    "rscpl",
    "ruby",
    "saxpath",
    "sax-pd",
    "scea",
    "sendmail",
    "sgi-b-1.0",
    "sgi-b-1.1",
    "sgi-b-2.0",
    "simpl-2.0",
    "sissl-1.2",
    "sissl",
    "sleepycat",
    "smlnj",
    "smppl",
    "snia",
    "spencer-86",
    "spencer-94",
    "spencer-99",
    "spl-1.0",
    "standardml-nj",
    "sugarcrm-1.1.3",
    "swl",
    "tcl",
    "tcp-wrappers",
    "tmate",
    "torque-1.1",
    "tosl",
    "unicode-dfs-2015",
    "unicode-dfs-2016",
    "unicode-tou",
    "unlicense",
    "upl-1.0",
    "vim",
    "vostrom",
    "vsl-1.0",
    "w3c-19980720",
    "w3c-20150513",
    "w3c",
    "watcom-1.0",
    "wsuipa",
    "wtfpl",
    "wxwindows",
    "x11",
    "xerox",
    "xfree86-1.1",
    "xinetd",
    "xnet",
    "xpp",
    "xskat",
    "ypl-1.0",
    "ypl-1.1",
    "zed",
    "zend-2.0",
    "zimbra-1.3",
    "zimbra-1.4",
    "zlib-acknowledgement",
    "zlib",
    "zpl-1.1",
    "zpl-2.0",
    "zpl-2.1",
    "389-exception",
    "autoconf-exception-2.0",
    "autoconf-exception-3.0",
    "bison-exception-2.2",
    "bootloader-exception",
    "classpath-exception-2.0",
    "clisp-exception-2.0",
    "digirule-foss-exception",
    "ecos-exception-2.0",
    "fawkes-runtime-exception",
    "fltk-exception",
    "font-exception-2.0",
    "freertos-exception-2.0",
    "gcc-exception-2.0",
    "gcc-exception-3.1",
    "gnu-javamail-exception",
    "i2p-gpl-java-exception",
    "libtool-exception",
    "linux-syscall-note",
    "lzma-exception",
    "mif-exception",
    "nokia-qt-exception-1.1",
    "occt-exception-1.0",
    "openvpn-openssl-exception",
    "qwt-exception-1.0",
    "u-boot-exception-2.0",
    "wxwindows-exception-3.1"
  ]

  def check(file) do
    if File.exists?(file.url <> ".license") do
      parse_file(file, file.url <> ".license", true)
    else
      if File.exists?(file.url <> ".licence") do
        parse_file(file, file.url <> ".licence", true)
      else
        parse_file(file, file.url, false)
      end
    end
  end

  defp parse_file(file_schema, file_path, license_found_in_dot_license) do
    case read_file(file_path) do
      {:ok,
       {has_copyright, has_license, spdx_license_expression, spdx_license_expression_is_valid,
        license_header_in_case_of_copyright_error, points_to_file}} ->
        {file_schema,
         %{
           has_copyright: has_copyright,
           license_found_in_debian_format: false,
           license_found_in_dot_license: license_found_in_dot_license and has_license,
           license_found_in_file: not license_found_in_dot_license and has_license,
           license_header_in_case_of_copyright_error: license_header_in_case_of_copyright_error,
           spdx_license_expression: spdx_license_expression,
           spdx_license_expression_is_valid: spdx_license_expression_is_valid,
           license_header_points_to_file: points_to_file,
           completed: true
         }}

      {:error, reason} ->
        Logger.info(reason)

        {file_schema,
         %{
           error: true,
           completed: true
         }}
    end
  end

  defp read_file(file) do
    case File.exists?(file) do
      true ->
        case File.stat(file) do
          {:ok, %{size: size}} ->
            case size > 5_000_000 do
              true ->
                {:error, "Warning: #{file} is too large, it will be skipped."}

              false ->
                body =
                  File.stream!(file, [:read], 4096)
                  |> Enum.at(0)

                {:ok, extract_copyright_and_license_information(body)}
            end

          {:error, _reason} ->
            {:error, "Warning: cannot determine the file size of #{file}."}
        end

      false ->
        {:error, "Warning: cannot find #{file}."}
    end
  end

  defp extract_copyright_and_license_information(file) when not is_nil(file) do
    spdx_identifier =
      if Regex.match?(~r/SPDX-Licen[cs]e-Identifier: .*(\*\/)*(-->)*$/Umi, file) do
        to_trim = Regex.replace(~r/.*SPDX-Licen[cs]e-Identifier:[ \t]+/si, file, "")
        Regex.replace(~r/[ \r\n\t].*/s, to_trim, "")
      else
        nil
      end

    spdx_is_valid = spdx_expression_is_valid(spdx_identifier)
    has_copyright = Regex.match?(~r/[Cc]opyright .*(\*\/)*(-->)*$/Umi, file)
    has_license = Regex.match?(~r/[Licen[cs]e/Umi, file)
    file_contents = Regex.replace(~r/\n[ \t]*[a-zA-Z0-9]+.*/s, file, "")

    points_to_file =
      case Regex.run(~r/Licen[cs]e-Filename: (.*)$/Umi, file, capture: :all_but_first) do
        nil ->
          nil

        [value] ->
          Regex.replace(~r/[ \r\n\t].*/s, value, "")
      end

    header =
      case has_copyright and has_license and String.valid?(file_contents) do
        true ->
          file_contents

        false ->
          nil
      end

    {has_copyright, has_license, spdx_identifier, spdx_is_valid, header, points_to_file}
  end

  defp extract_copyright_and_license_information(_file) do
    {false, false, nil, false, nil, nil}
  end

  def spdx_expression_is_valid(spdx_identifier) when not is_nil(spdx_identifier) do
    Logger.debug("Checking SPDX expression #{spdx_identifier}.")

    invalid_spdx_identifiers_found =
      spdx_identifier
      |> String.replace("(", "")
      |> String.replace(")", "")
      |> String.downcase()
      |> String.split([" and ", " or ", " with "], trim: true)
      |> Enum.map(fn license -> String.replace_trailing(license, "-or-later", "") end)
      |> Enum.map(fn license -> String.replace_trailing(license, "+", "") end)
      |> Enum.filter(fn item ->
        not Enum.member?(@spdx_identifiers, item) and not String.starts_with?(item, "licenseref-")
      end)

    Enum.count(invalid_spdx_identifiers_found) == 0
  end

  def spdx_expression_is_valid(_spdx_identifier) do
    false
  end
end
