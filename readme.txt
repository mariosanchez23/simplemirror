# About
This is a No VIP mirror configuration.
(VIP dosen't work in container anyway.)

# How to setup.
I'm using Dmitriy's web gateway container.
https://community.intersystems.com/post/apache-and-containerised-iris

You have to build it after overwrting webgateway-entrypoint.sh and webgateway.conf provided by my repo in order to make it 
- mirror aware
- recognize /api/

$ git clone https://github.com/IRISMeister/simplemirror.git
$ git clone https://github.com/caretdev/iris-webgateway-example
$ copy ./simplemirror/webgateway-entrypoint.sh iris-webgateway-example/
$ copy ./simplemirror/webgateway.conf iris-webgateway-example/
$ cd iris-webgateway-example
$ docker-compose build
$ cd ../simplemirror

$ ./start.sh
 or
$ ./start-single-bridge.sh   (mimics typical cloud env where you have only one NIC)

To force some events in Arbiter Controlled Mode 
https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GHA_mirror_set#GHA_mirror_set_autofail_details_arbmode

If the connection between the primary and the backup is broken in arbiter controlled mode, each failover member responds based on the state of the arbiter connections as described in the following.
- Primary Loses Connection to Backup
1)If the primary loses its connection to an active backup, or exceeds the QoS timeout waiting for it to 
This is 6th case of Mirror Responses to Lost Connections.
https://docs.intersystems.com/irislatest/csp/docbook/images/gha_mirror_response_lost_connections.png

$ docker network disconnect simplemirror_iris-tier mirrorB ; docker network disconnect simplemirror_arbiter-tier mirrorB
...mirrorA will be switche to "agent controlled mode"

$ docker-compose exec mirrorB iris session iris -U %SYS MIRROR
%SYS>D ^MIRROR
1) Mirror Status
4) Status Monitor
Status of Mirror MIRRORSET at 10:15:59 on 12/24/2020
Incoming Journal Transfer Rate for This Member (over refresh interval)
 0.00 KB/s (11s interval)

Arbiter Connection Status:
     Arbiter Address:   10.0.100.10|2188
     Failover Mode:     Agent Controlled
     Connection Status: This member is not connected to the arbiter

                                       Journal Transfer
Member Name+Type            Status        Latency       Dejournal Latency
--------------------------  ---------  ---------------  --------------
MIRRORA
     Failover               Down       Disconnected on 12/24/2020 10:15:15.12
MIRRORB
     Failover               Waiting    Disconnected on 12/24/2020 10:15:15.12



2)If the primary learns that the arbiter is still connected to the backup
This is 4th case of Mirror Responses to Lost Connections.
$ docker network disconnect simplemirror_iris-tier mirrorA

3)If the primary has lost its arbiter connection as well as its connection to the backup, it remains in the trouble state indefinitely so that the backup can safely take over. 
If failover occurs, when the connection is restored the primary shuts down.
This is 7th case of Mirror Responses to Lost Connections.
!!! This is the only case which backup takes over automatically !!!

$ docker network disconnect simplemirror_iris-tier mirrorA ; docker network disconnect simplemirror_arbiter-tier mirrorA
...mirrorB will become Primary automatically.

$ docker network connect simplemirror_iris-tier mirrorA 
...eventually mirrorA will be force shutdown.
$ docker-compose exec mirrorA iris list
        status:       down, last used Thu Dec 24 09:21:10 2020


----
# Web endpoints

web g/w portal
http://irishost:9092/csp/bin/Systems/Module.cxw      (via built-in apache for mirrorA) ->You are not authorized to use this facility
http://irishost:9093/csp/bin/Systems/Module.cxw      (via built-in apache for mirrorB) ->You are not authorized to use this facility
http://irishost:8080/csp/bin/Systems/Module.cxw      (via webgw1)
http://irishost:8081/csp/bin/Systems/Module.cxw      (via webgw2)
http://irishost/csp/bin/Systems/Module.cxw           (via NGINX, primary member)

system management portal
http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen  (via built-in apache for mirrorA)
http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen  (via built-in apache for mirrorB)
http://irishost:8080/csp/sys/%25CSP.Portal.Home.zen  (via webgw1, primary member)
http://irishost:8081/csp/sys/%25CSP.Portal.Home.zen  (via webgw2, primary member)
http://irishost/csp/sys/%25CSP.Portal.Home.zen       (via NGINX, primary member)
Only NGINX Plus (not free) has Active Health Checks ability. So it's passive (meaning not using mirror_status.cxw).

REST APIs
http://irishost:9092/api/mgmnt/ -u SuperUser:SYS  (via built-in apache for mirrorA)
http://irishost:9093/api/mgmnt/ -u SuperUser:SYS  (via built-in apache for mirrorB)
http://irishost:8080/api/mgmnt/ -u SuperUser:SYS  (via webgw1, primary member)
http://irishost:8081/api/mgmnt/ -u SuperUser:SYS  (via webgw2, primary member)
http://irishost/api/mgmnt/ -u SuperUser:SYS       (via NGINX, primary member)

Health Check for NGINX(LB) (with mirror aware webgw, you probably don't need this)
http://irishost:8080/csp/a/mirror_status.cxw    (via webgw1, mirrorA)
http://irishost:8080/csp/b/mirror_status.cxw    (via webgw1, mirrorB)
http://irishost:8081/csp/a/mirror_status.cxw    (via webgw2, mirrorA)
http://irishost:8081/csp/b/mirror_status.cxw    (via webgw2, mirrorB)


------------------
App REST
## MirrorA:Primary, MirrorB:Backup 
$ curl http://irishost:8080/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorA",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:17:09",
  "ImageBuilt": ""
}
$ curl http://irishost:8081/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorA",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:17:35",
  "ImageBuilt": ""
}
$ curl http://localhost/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorA",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:17:40",
  "ImageBuilt": ""
}

## MirrorA:Stop, MirrorB:Primary 
$ docker-compose stop mirrorA
$ curl http://irishost:8080/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorB",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:18:22",
  "ImageBuilt": ""
}
$ curl http://irishost:8081/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorB",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:18:29",
  "ImageBuilt": ""
}
$ curl http://localhost/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorB",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:18:34",
  "ImageBuilt": ""
}
## MirrorA:Stop, MirrorB:Primary, webgw1:Stop, webgw2:Alive

$ docker-compose stop webgw1
Stopping webgw ... done
$ curl http://irishost:8080/csp/mirrorns/get -u SuperUser:SYS
curl: (7) Failed to connect to localhost port 8080: 接続を拒否されました
$ curl http://irishost:8081/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorB",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:20:05",
  "ImageBuilt": ""
}
$ curl http://localhost/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "mirrorB",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/24/2021 15:20:32",
  "ImageBuilt": ""
}

------------------
HealthCheck endpoints and their behaivor. These are what LB will see.
http://irishost:8080/csp/a/mirror_status.cxw    (via webgw1, mirrorA)
http://irishost:8080/csp/b/mirror_status.cxw    (via webgw1, mirrorB)
http://irishost:8081/csp/a/mirror_status.cxw    (via webgw2, mirrorA)
http://irishost:8081/csp/b/mirror_status.cxw    (via webgw2, mirrorB)


$ curl -m 5 http://irishost:8080/csp/a/mirror_status.cxw -v
$ curl -m 5 http://irishost:8081/csp/a/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS
$ curl -m 5 http://irishost:8080/csp/b/mirror_status.cxw -v
$ curl -m 5 http://irishost:8081/csp/b/mirror_status.cxw -v
< HTTP/1.1 503 Service Unavailable
FALIED

$ docker-compose exec mirrorA iris stop iris quietly
$ curl -m 5 http://irishost:8080/csp/b/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS

$ docker-compose exec mirrorA iris start iris quietly
$ curl -m 5 http://irishost:8080/csp/a/mirror_status.cxw -v
< HTTP/1.1 503 Service Unavailable
FAILED

$ docker-compose exec mirrorB iris stop iris quietly
$ curl -m 5 http://irishost:8080/csp/a/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS

$ curl -m 5 http://irishost:8080/csp/b/mirror_status.cxw -v
curl: (28) Operation timed out after 5000 milliseconds with 0 bytes received


Let's abuse to see nothing wrong happens.
$ curl -m 5 http://irishost:8080/csp/a/mirror_status.cxw?[1-20]

If you see lots of [Status=Server], disable it.
[SYSTEM]
REGISTRY_METHODS=Disabled
https://wrc.intersystems.com/wrc/ProblemViewTabs.csp?OBJID=903951

------

My tests to see if Virtual IP is available in container or not... I guess not.

root@mirrorA:/home/irisowner# apt-get update
root@mirrorA:/home/irisowner# apt-get install -y arping
root@mirrorA:/home/irisowner# apt -y install network-manager

root@mirrorA:/home/irisowner# nmcli c m eth0 +ipv4.address 10.0.100.5/24
Error: Could not create NMClient object: Could not connect: No such file or directory.
root@mirrorA:/home/irisowner#
root@mirrorA:/home/irisowner# ip addr add 10.0.100.5/24 dev eth0
RTNETLINK answers: Operation not permitted

-----
Interesting read.
https://qiita.com/BooookStore/items/5862515209a31658f88c