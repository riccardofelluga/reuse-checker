#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>


#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"]{IpN!a/5??j}K/6CJQ>F=mf{b>&5QF,OCxXbs%*LP>>1&3r$=:_g$IZ);A@ntJb")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"k*aXOa%Sp6|*$TQwqPhWc0i20HMqA7GGYn;&jZ4tku_no`4hQtHD1DU$%cF)A7?(")
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :reuse do
  set(version: current_version(:reuse))
  set(applications: [:runtime_tools, reuse: :permanent])
  
  set(
    commands: [
      migrate: "rel/commands/migrate.sh"
    ]
  )
end
