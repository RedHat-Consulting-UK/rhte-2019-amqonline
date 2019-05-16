#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Generating certs... $WHITE"
echo ""

NAMESPACE=$OPERATOR_NS
CLUSTER=$(oc get ingress.config/cluster -o jsonpath='{.spec.domain}')

export NAMESPACE
export CLUSTER
source ./lab/scenario2/1_amq-admin/solution/k8s-tls/create

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc create secret tls iot-mqtt-adapter-tls -n "$OPERATOR_NS" --key=lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-mqtt-adapter-key.pem --cert=lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-mqtt-adapter-fullchain.pem
oc create secret tls iot-http-adapter-tls -n "$OPERATOR_NS" --key=lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-http-adapter-key.pem --cert=lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-http-adapter-fullchain.pem

oc apply -f lab/scenario2/1_amq-admin/solution -n "$OPERATOR_NS"

echo ""
echo -e "$GREEN Sleeping for 2mins to let the pods start up... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Only showing the enmasse related pods in $OPERATOR_NS - if you dont see pods. investigate! $WHITE"
echo ""

oc get pods -n "$OPERATOR_NS" -l app=enmasse --sort-by='{.metadata.creationTimestamp}'

echo ""
echo -e "$GREEN Show all created resources in $OPERATOR_NS $WHITE"
echo ""

oc get IoTConfig -n "$OPERATOR_NS" --show-kind