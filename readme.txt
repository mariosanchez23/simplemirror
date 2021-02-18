# About
This is a No VIP mirror configuration.
(VIP dosen't work in container anyway.)

# How to setup.
I'm using Dmitriy's web gateway container.
https://community.intersystems.com/post/apache-and-containerised-iris

You have to build it after overwrting webgateway-entrypoint.sh provided by my repo.
$ git clone https://github.com/IRISMeister/simplemirror.git
$ git clone https://github.com/caretdev/iris-webgateway-example
$ copy ./simplemirror/webgateway-entrypoint.sh iris-webgateway-example/
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

csp portal
http://irishost/csp/bin/Systems/Module.cxw           (via webgw container)
http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen  (mirrorA)
http://irishost:9093/csp/sys/%25CSP.Portal.Home.zen  (mirrorB)


HealthCheck endpoints and their behaivor. These are what LB will see.
$ curl -m 5 http://localhost/csp/a/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS

Let's abuse to see what happens.
$ curl -m 5 http://localhost/csp/a/mirror_status.cxw?[1-20]

If you see lots of [Status=Server], disable it.
[SYSTEM]
REGISTRY_METHODS=Disabled
https://wrc.intersystems.com/wrc/ProblemViewTabs.csp?OBJID=903951

$ curl -m 5 http://localhost/csp/b/mirror_status.cxw -v
< HTTP/1.1 503 Service Unavailable
FAILED

$ docker-compose exec mirrorA iris stop iris quietly
$ curl -m 5 http://localhost/csp/b/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS

$ docker-compose exec mirrorA iris start iris quietly
$ curl -m 5 http://localhost/csp/a/mirror_status.cxw -v
< HTTP/1.1 503 Service Unavailable
FAILED

$ docker-compose exec mirrorB iris stop iris quietly
$ curl -m 5 http://localhost/csp/a/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS

$ curl -m 5 http://localhost/csp/b/mirror_status.cxw -v
curl: (28) Operation timed out after 5000 milliseconds with 0 bytes received

------

Ny tests to see if Virtual IP is available or not... I guess not.

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