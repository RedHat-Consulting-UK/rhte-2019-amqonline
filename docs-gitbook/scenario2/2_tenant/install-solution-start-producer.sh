#!/usr/bin/env bash

source lab/install-solution-common.sh

MQTT_ROUTEURL=$(oc get routes -n "$OPERATOR_NS" iot-mqtt-adapter -o jsonpath='{.spec.host}')
HTTP_ADAPTERURL=$(oc get routes -n "$OPERATOR_NS" iot-http-adapter -o jsonpath='{.spec.host}')

echo ""
echo -e "$GREEN Attempting to send telemetry data to mqtt adapter $MQTT_ROUTEURL - if you see errors - investigate! $WHITE"
echo ""

mosquitto_pub -d -h "$MQTT_ROUTEURL" -p 443 -u 'sensor1@epht-smarttruck.iot' -P password -t telemetry -m '{"temp": 5}' --cafile lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-mqtt-adapter-fullchain.pem
mosquitto_pub -d -h "$MQTT_ROUTEURL" -p 443 -u 'sensor1@epht-smarttruck.iot' -P password -t event -m '{"door_opened": "true"}' --cafile lab/scenario2/1_amq-admin/solution/k8s-tls/build/iot-mqtt-adapter-fullchain.pem

echo ""
echo -e "$GREEN Attempting to send telemetry data to http adapter $HTTP_ADAPTERURL - if the http code is not 202 - investigate! $WHITE"
echo ""

curl -k -v -X POST "https://$HTTP_ADAPTERURL/telemetry" -u sensor1@epht-smarttruck.iot:password --data-binary '{"temp": 10}'
curl -k -v -X POST "https://$HTTP_ADAPTERURL/event" -u sensor1@epht-smarttruck.iot:password --data-binary '{"door_opened": "false"}'