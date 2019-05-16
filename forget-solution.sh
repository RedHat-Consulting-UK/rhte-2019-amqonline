#!/usr/bin/env bash

git rm --cached apply-solution.adoc

git rm --cached -r lab/scenario1/0_ocp-admin/solution/
git rm --cached -r lab/scenario1/1_amq-admin/solution/
git rm --cached -r lab/scenario1/2_tenant/solution/

git rm --cached -r lab/scenario2/0_ocp-admin/solution/
git rm --cached -r lab/scenario2/1_amq-admin/solution/
git rm --cached -r lab/scenario2/2_tenant/solution/

git rm --cached lab/scenario1/0_ocp-admin/install-solution.sh
git rm --cached lab/scenario1/1_amq-admin/install-solution.sh
git rm --cached lab/scenario1/2_tenant/install-solution.sh

git rm --cached lab/scenario2/0_ocp-admin/install-solution.sh
git rm --cached lab/scenario2/1_amq-admin/install-solution.sh
git rm --cached lab/scenario2/2_tenant/install-solution.sh

git rm --cached lab/scenario2/2_tenant/install-solution-build-hono-cli.sh
git rm --cached lab/scenario2/2_tenant/install-solution-start-consumer.sh
git rm --cached lab/scenario2/2_tenant/install-solution-start-producer.sh