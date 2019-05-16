#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Cloning and building eclipse-hono cli via mvn - expected you have git, mvn and java11 configured! $WHITE"
echo ""

j11 2>/dev/null

rm -rf /tmp/eclipse-hono

CURRENTDIR=$(pwd)

git clone https://github.com/eclipse/hono.git /tmp/eclipse-hono
cd /tmp/eclipse-hono || return
git checkout tags/0.9 -b 0.9

cd cli || return
mvn package -am

cd "$CURRENTDIR" || return