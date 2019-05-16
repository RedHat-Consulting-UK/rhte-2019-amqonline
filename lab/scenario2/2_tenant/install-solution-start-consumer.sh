#!/usr/bin/env bash

source lab/install-solution-common.sh

AMQP_ROUTEURL=$(oc get AddressSpace -n "$APP_NS" iot -o jsonpath='{.status.endpointStatuses[?(@.name == "messaging")].externalHost}')

echo ""
echo -e "$GREEN Starting eclipse-hono cli connected to $AMQP_ROUTEURL - expected you have mvn and java11 configured! $WHITE"
echo ""

j11 2>/dev/null

mvn -f /tmp/eclipse-hono/cli spring-boot:run \
    -Drun.arguments=--hono.client.host="$AMQP_ROUTEURL",--hono.client.port=443,--tenant.id=epht-smarttruck.iot,--hono.client.username=truck1,--hono.client.password=password,--message.type=all,--hono.client.trustStorePath=/tmp/eclipse-hono/cli/target/config/hono-demo-certs-jar/tls.crt