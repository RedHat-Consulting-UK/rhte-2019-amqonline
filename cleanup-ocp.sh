#!/usr/bin/env bash

# Set colours
GREEN="\e[32m"
WHITE="\e[0m"

export OPERATOR_NS=openshift-operators
export APP_NS=epht-smarttruck

oc delete AddressSpace -n $APP_NS --all
oc delete Address -n $APP_NS --all
oc delete IoTProject -n $APP_NS --all
oc delete MessagingUser -n $APP_NS --all

echo ""
echo -e "$GREEN Sleeping for 30seconds to let tenant be deleted... $WHITE"
sleep 30

oc delete ConsoleService -n $OPERATOR_NS --all
oc delete AuthenticationService -n $OPERATOR_NS --all
oc delete StandardInfraConfig -n $OPERATOR_NS --all
oc delete AddressSpacePlan -n $OPERATOR_NS --all
oc delete AddressPlan -n $OPERATOR_NS --all
oc delete IoTConfig -n $OPERATOR_NS --all

echo ""
echo -e "$GREEN Sleeping for 30seconds to let admin plans be deleted... $WHITE"
sleep 30

oc delete secret/iot-mqtt-adapter-tls -n $OPERATOR_NS
oc delete secret/iot-http-adapter-tls -n $OPERATOR_NS

oc delete Deployment/iot-operator -n $OPERATOR_NS
oc delete sa/iot-operator -n $OPERATOR_NS

oc delete ClusterServiceVersion/enmasse.0.28.0 -n $OPERATOR_NS
oc delete Subscription/enmasse -n $OPERATOR_NS

echo ""
echo -e "$GREEN Sleeping for 30seconds to let admin be deleted... $WHITE"
sleep 30

oc delete project $APP_NS