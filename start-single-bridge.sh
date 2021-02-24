#!/bin/bash
docker-compose -f docker-compose-single-ni.yml up -d mirrorA
docker-compose -f docker-compose-single-ni.yml exec -T mirrorA bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose -f docker-compose-single-ni.yml up -d mirrorB
docker-compose -f docker-compose-single-ni.yml up -d webgw1 webgw2 nginx
docker-compose -f docker-compose-single-ni.yml ps
