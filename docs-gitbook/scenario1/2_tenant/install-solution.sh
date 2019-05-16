#!/usr/bin/env bash

source lab/install-solution-common.sh

echo ""
echo -e "$GREEN Applying resources... $WHITE"
echo ""

oc new-project "$APP_NS"
oc apply -f lab/scenario1/2_tenant/solution -n "$APP_NS"

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

oc get AddressSpace,Address,MessagingUser -o wide -n "$APP_NS" --show-kind

echo ""
echo -e "$GREEN Sleeping for 2mins to let the address-space-controller to reconcile... $WHITE"
sleep 120

echo ""
echo -e "$GREEN Checking logs for address-space-controller pod in $OPERATOR_NS - you should not see errors, if you do - investigate! $WHITE"
echo ""

oc logs "$(oc get pods -n "$OPERATOR_NS" -l name=address-space-controller -o jsonpath='{.items[0].metadata.name}')" -n "$OPERATOR_NS" --tail=100

echo ""
echo -e "$GREEN Downloading cli-qpid-jms from engineering repo - REQUIRES VPN! $WHITE"
echo ""

curl -L http://messaging-qe-repo.usersys.redhat.com:8081/artifactory/cli-java/cli-qpid-jms-1.2.2-SNAPSHOT-0.42.0.redhat-00002.jar -o cli-artemis-jms.jar

ROUTEURL=$(oc get AddressSpace -n "$APP_NS" smarttruck -o jsonpath='{.status.endpointStatuses[?(@.name == "messaging")].externalHost}')
SERVICEURL=$(oc get AddressSpace -n "$APP_NS" smarttruck -o jsonpath='{.status.endpointStatuses[?(@.name == "messaging")].serviceHost}')

echo ""
echo -e "$GREEN Attempting to send/receive via cli-qpid-jms (off-cluster AMQP test) - $ROUTEURL $WHITE"
echo ""

java -jar cli-artemis-jms.jar sender --broker-uri "amqps://$ROUTEURL:443?jms.username=truck1&jms.password=password&amqp.saslMechanisms=PLAIN&transport.trustAll=True&transport.verifyHost=False" --log-msgs dict  --log-lib debug --address driver_notifications
java -jar cli-artemis-jms.jar receiver --broker-uri "amqps://$ROUTEURL:443?jms.username=truck1&jms.password=password&amqp.saslMechanisms=PLAIN&transport.trustAll=True&transport.verifyHost=False" --log-msgs dict  --log-lib debug --address driver_notifications

echo ""

java -jar cli-artemis-jms.jar sender --broker-uri "amqps://$ROUTEURL:443?jms.username=truck1&jms.password=password&amqp.saslMechanisms=PLAIN&transport.trustAll=True&transport.verifyHost=False" --log-msgs dict  --log-lib debug --address truck_notifications
java -jar cli-artemis-jms.jar receiver --broker-uri "amqps://$ROUTEURL:443?jms.username=truck1&jms.password=password&amqp.saslMechanisms=PLAIN&transport.trustAll=True&transport.verifyHost=False" --log-msgs dict  --log-lib debug --address truck_notifications

echo ""
echo -e "$GREEN Attempting to send/receive via quiver (on-cluster AMQP test) - $SERVICEURL $WHITE"
echo ""

oc delete pods -l app=quiver -n "$APP_NS"

oc import-image quiver:latest --from=docker.io/ssorj/quiver --confirm -n "$APP_NS"
oc process -f https://raw.githubusercontent.com/ssorj/quiver/0.3.0/packaging/openshift/openshift-pod-template.yml \
    DOCKER_IMAGE="$(oc get is quiver -n "$APP_NS" -o jsonpath='{.status.dockerImageRepository}')":latest \
    DOCKER_CMD="[\"quiver\", \"amqps://truck1:password@$SERVICEURL:5671/driver_notifications\", \"--count\", \"100\", \"--timeout\", \"30\", \"--impl\", \"qpid-jms\", \"--verbose\"]" \
    | oc create -n "$APP_NS" -f -

oc process -f https://raw.githubusercontent.com/ssorj/quiver/0.3.0/packaging/openshift/openshift-pod-template.yml \
    DOCKER_IMAGE="$(oc get is quiver -n "$APP_NS" -o jsonpath='{.status.dockerImageRepository}')":latest \
    DOCKER_CMD="[\"quiver\", \"amqps://truck1:password@$SERVICEURL:5671/truck_notifications\", \"--count\", \"100\", \"--timeout\", \"30\", \"--impl\", \"qpid-jms\", \"--verbose\"]" \
    | oc create -n "$APP_NS" -f -

oc get pods -n "$APP_NS"

echo ""
echo "$GREEN Sleeping for 2mins to let the quiver pods start up... $WHITE"
sleep 120

QUIVERPOD0=$(oc get pods -n "$APP_NS" -l app=quiver -o jsonpath='{.items[0].metadata.name}')
QUIVERPOD1=$(oc get pods -n "$APP_NS" -l app=quiver -o jsonpath='{.items[1].metadata.name}')

echo ""
echo -e "$GREEN Attempting to follow logs of $QUIVERPOD0 and $QUIVERPOD1 pod. if the logs dont show a nice table of messages sent/received, something is probably wrong... $WHITE"
echo ""

oc logs -n "$APP_NS" "$QUIVERPOD0"

echo ""

oc logs -n "$APP_NS" "$QUIVERPOD1"