#!/bin/bash
chmod -fR 777 iris1A 
chmod -fR 777 iris1B 
chmod -fR 777 iris2A 
chmod -fR 777 iris2B 
# primaries
docker-compose up -d ap1a ap2a
docker-compose exec -T ap1a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T ap2a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
# join backups
docker-compose up -d ap1b ap2b
docker-compose exec -T ap1b bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T ap2b bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
# webgws and LBs
docker-compose up -d webgw1 webgw2 nginx haproxy
# give them a moment
sleep 10
docker-compose ps
