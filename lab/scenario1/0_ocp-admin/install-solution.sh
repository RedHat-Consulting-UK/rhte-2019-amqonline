#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc apply -f lab/scenario1/0_ocp-admin/solution/0_Operator.yaml

echo ""
echo -e "$GREEN Sleeping for 2mins to let the pods start up... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Only showing the enmasse related pods in $OPERATOR_NS - if you dont see pods. investigate! $WHITE"
echo ""

oc get pods -n "$OPERATOR_NS" -l app=enmasse --sort-by='{.metadata.creationTimestamp}'

echo ""
echo -e "$GREEN Only showing the enmasse related pods in $MARKETPLACE_NS - if you dont see pods. investigate! $WHITE"
echo ""

oc get pods -n "$MARKETPLACE_NS" -l marketplace.catalogSourceConfig=enmasse-operators --sort-by='{.metadata.creationTimestamp}'