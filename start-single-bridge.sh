#!/bin/bash
# primaries
docker-compose -f docker-compose-single-ni.yml up -d ap1a
docker-compose -f docker-compose-single-ni.yml up -d ap2a
docker-compose -f docker-compose-single-ni.yml exec -T ap1a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose -f docker-compose-single-ni.yml exec -T ap2a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
# join backups
docker-compose -f docker-compose-single-ni.yml up -d ap1b
docker-compose -f docker-compose-single-ni.yml up -d ap2b
# webgws and LB
docker-compose -f docker-compose-single-ni.yml up -d webgw1 webgw2 nginx
docker-compose -f docker-compose-single-ni.yml ps
