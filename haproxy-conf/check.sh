#!/bin/bash
# -N is to avoid '(23) Failed writing body' error
status=`curl -m 5 http://${HAPROXY_SERVER_NAME}:52773/csp/mirror_status.cxw -sN`
if [[ $status = "SUCCESS" ]] ;then
 exit 0
else
 exit 1
fi