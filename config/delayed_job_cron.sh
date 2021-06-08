#!/bin/bash
APP_PATH="$HOME/decidim_app"

if ! [ -s $APP_PATH/tmp/pids/delayed_job.pid ]; then
  RAILS_ENV=production $APP_PATH/bin/delayed_job start
fi
