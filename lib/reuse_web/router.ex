#
# Copyright (c) 2018 Andrea Janes <ajanes@unibz.it>, Riccardo Felluga <riccardo.felluga@stud-inf.unibz.it>, Max Schweigkofler <maxelia.schweigkofler@stud-inf.unibz.it>
#
# This file is part of the project reuse-checker which is released under the MIT license.
# See file LICENSE or go to https://github.com/riccardofelluga/reuse-checker for full license details.
# 
# SPDX-License-Identifier: MIT
#

defmodule ReuseWeb.Router do
  use ReuseWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ReuseWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/check", PageController, :check)
    get("/dispatch", PageController, :dispatch)
    get("/abort", PageController, :abort)
    get("/clean", PageController, :clean)
    get("/clean_unfinished", PageController, :clean_unfinished)
    get("/study", PageController, :study)
    get("/results", PageController, :results)
    post("/analyzing", PageController, :analyzing)
    get("/analyze", PageController, :analyze)
    get("/contacts", PageController, :contacts)
    get("/terms", PageController, :terms)
    get("/privacy", PageController, :privacy)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ReuseWeb do
  #   pipe_through :api
  # end
end
