#!/bin/sh

./script/rstakeout "./script/cucumber $*" "app/**/*.rb" "features/**/*" "spec/**/*.rb" "config/*.rb"