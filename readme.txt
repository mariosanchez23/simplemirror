To force some events in Arbiter Controlled Mode 
https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GHA_mirror_set#GHA_mirror_set_autofail_details_arbmode

If the connection between the primary and the backup is broken in arbiter controlled mode, each failover member responds based on the state of the arbiter connections as described in the following.
- Primary Loses Connection to Backup
1)If the primary loses its connection to an active backup, or exceeds the QoS timeout waiting for it to 
This is 6th case of Mirror Responses to Lost Connections.
https://docs.intersystems.com/irislatest/csp/docbook/images/gha_mirror_response_lost_connections.png

# docker network disconnect simplemirror_iris-tier mirrorB ; docker network disconnect simplemirror_arbiter-tier mirrorB
...mirrorA will be switche to "agent controlled mode"

# docker-compose exec mirrorB iris session iris -U %SYS MIRROR
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
# docker network disconnect simplemirror_iris-tier mirrorA

3)If the primary has lost its arbiter connection as well as its connection to the backup, it remains in the trouble state indefinitely so that the backup can safely take over. 
If failover occurs, when the connection is restored the primary shuts down.
This is 7th case of Mirror Responses to Lost Connections.
!!! This is the only case which backup takes over automatically !!!

# docker network disconnect simplemirror_iris-tier mirrorA ; docker network disconnect simplemirror_arbiter-tier mirrorA
...mirrorB will become Primary automatically.

# docker network connect simplemirror_iris-tier mirrorA 
...eventually mirrorA will be force shutdown.
# docker-compose exec mirrorA iris list
        status:       down, last used Thu Dec 24 09:21:10 2020

