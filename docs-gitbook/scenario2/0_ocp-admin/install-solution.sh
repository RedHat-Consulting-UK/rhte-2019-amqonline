#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc apply -f lab/scenario2/0_ocp-admin/solution -n "$OPERATOR_NS"

echo ""
echo -e "$GREEN Sleeping for 2mins to let the pods start up... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Only showing the enmasse related pods in $OPERATOR_NS $WHITE"
echo ""

oc get pods -n "$OPERATOR_NS" -l app=enmasse --sort-by='{.metadata.creationTimestamp}'