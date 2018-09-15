# 
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
# 

defmodule ReuseWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such as controllers, views,
  channels and so on.

  This can be used in your application as:

      use ReuseWeb, :controller
      use ReuseWeb, :view

  The definitions below will be executed for every view, controller, etc, so
  keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below. Instead, define
  any helper function in modules and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ReuseWeb
      import Plug.Conn
      import ReuseWeb.Router.Helpers
      import ReuseWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/reuse_web/templates",
        namespace: ReuseWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ReuseWeb.Router.Helpers
      import ReuseWeb.ErrorHelpers
      import ReuseWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ReuseWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
