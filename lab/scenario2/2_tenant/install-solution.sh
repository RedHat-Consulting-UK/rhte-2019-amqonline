#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc apply -f lab/scenario2/2_tenant/solution -n "$APP_NS"

echo ""
echo -e "$GREEN Sleeping for 2mins to let the pods start up... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Only showing the enmasse related pods, routes and services in $OPERATOR_NS $WHITE"
echo ""

oc get pods -n "$OPERATOR_NS" -l app=enmasse --sort-by='{.metadata.creationTimestamp}'
echo ""
oc get svc,route -n "$OPERATOR_NS" --show-kind

echo ""
echo -e "$GREEN Show all created resources $APP_NS - if the status is not true - investigate! $WHITE"
echo ""

oc get AddressSpace,Address,IoTProject,MessagingUser -o wide -n "$APP_NS" --show-kind

echo ""
echo -e "$GREEN Checking logs for address-space-controller pod in $OPERATOR_NS - you should not see errors, if you do - investigate! $WHITE"
echo ""

oc logs "$(oc get pods -n "$OPERATOR_NS" -l name=address-space-controller -o jsonpath='{.items[0].metadata.name}')" -n "$OPERATOR_NS" --tail=50

REGISTRYURL=$(oc get routes -n "$OPERATOR_NS" device-registry -o jsonpath='{.spec.host}')

echo ""
echo -e "$GREEN Attempting to register device against registry $REGISTRYURL - if the http code is not 201 - investigate! $WHITE"
echo ""

curl --insecure -X POST -i -H 'Content-Type: application/json' --data-binary '{"device-id": "1"}' "https://$REGISTRYURL/registration/epht-smarttruck.iot"
curl --insecure -X POST -i -H 'Content-Type: application/json' --data-binary '{"device-id": "1","type": "hashed-password","auth-id": "sensor1","secrets": [{"hash-function" : "sha-512","pwd-plain":"'password'"}]}' "https://$REGISTRYURL/credentials/epht-smarttruck.iot"

oc get AddressSpace -n "$APP_NS" iot -o jsonpath='{.status.caCert}' | base64 --decode > /tmp/eclipse-hono/cli/target/config/hono-demo-certs-jar/tls.crt

echo ""
echo -e "$GREEN Attempting to send/receive via quiver (on-cluster AMQP test) - $SERVICEURL $WHITE"
echo ""

oc delete pods -l app=quiver -n "$APP_NS"

SERVICEURL=$(oc get AddressSpace -n "$APP_NS" iot -o jsonpath='{.status.endpointStatuses[?(@.name == "messaging")].serviceHost}')

oc process -f https://raw.githubusercontent.com/ssorj/quiver/0.3.0/packaging/openshift/openshift-pod-template.yml \
    DOCKER_IMAGE="$(oc get is quiver -n "$APP_NS" -o jsonpath='{.status.dockerImageRepository}')":latest \
    DOCKER_CMD="[\"quiver\", \"amqps://truck1:password@$SERVICEURL:5671/event/epht-smarttruck.iot\", \"--count\", \"100\", \"--timeout\", \"30\", \"--impl\", \"qpid-jms\", \"--verbose\"]" \
    | oc create -n "$APP_NS" -f -

echo ""
echo "$GREEN Sleeping for 2mins to let the quiver pods start up... $WHITE"
sleep 120

QUIVERPOD0=$(oc get pods -n "$APP_NS" -l app=quiver -o jsonpath='{.items[0].metadata.name}')

echo ""
echo -e "$GREEN Attempting to follow logs of $QUIVERPOD0 pod. if the logs dont show a nice table of messages sent/received, something is probably wrong... $WHITE"
echo ""

oc logs -n "$APP_NS" "$QUIVERPOD0"