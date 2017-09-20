#!/bin/sh

. /config.prometheus

sed "s,ALERT_SLACK_USERNAME,${ALERT_SLACK_USERNAME},g;
s,ALERT_SLACK_CHANNEL,${ALERT_SLACK_CHANNEL},g;
s,ALERT_SLACK_INCOMING_WEBHOOK_URL,${ALERT_SLACK_INCOMING_WEBHOOK_URL},g"
/config/alertmanager.template.yml > /config/alertmanager.yml
