#!/usr/bin/env bash

#npm install gitbook-cli -g

rm -rf docs-gitbook/

gitbook build lab/ docs-gitbook/
gitbook serve lab/ docs-gitbook/ --port 4000