#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc apply -f lab/scenario1/1_amq-admin/solution -n "$OPERATOR_NS"

echo ""
echo -e "$GREEN Sleeping for 2mins to let the pods start up... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Only showing the enmasse related pods in $OPERATOR_NS - if you dont see pods. investigate! $WHITE"
echo ""

oc get pods -n "$OPERATOR_NS" -l app=enmasse --sort-by='{.metadata.creationTimestamp}'

echo ""
echo -e "$GREEN Show all created resources $APP_NS - if the status is not true - investigate! $WHITE"
echo ""

oc get AuthenticationService,StandardInfraConfig,AddressSpacePlan,AddressPlan -n "$OPERATOR_NS" --show-kind

echo ""
echo -e "$GREEN Sleeping for 2mins to let the address-space-controller to reconcile... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Checking logs for address-space-controller pod in $OPERATOR_NS - you should not see errors, if you do - investigate! $WHITE"
echo ""

oc logs "$(oc get pods -n "$OPERATOR_NS" -l name=address-space-controller -o jsonpath='{.items[0].metadata.name}')" -n "$OPERATOR_NS" --tail=100