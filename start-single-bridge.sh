#!/bin/bash
# primaries
docker-compose -f docker-compose-single-bridge.yml up -d ap1a ap2a
docker-compose -f docker-compose-single-bridge.yml exec -T ap1a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose -f docker-compose-single-bridge.yml exec -T ap2a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
# join backups
docker-compose -f docker-compose-single-bridge.yml up -d ap1b ap2b
# webgws and LB
docker-compose -f docker-compose-single-bridge.yml up -d webgw1 webgw2 nginx haproxy
docker-compose -f docker-compose-single-bridge.yml ps
