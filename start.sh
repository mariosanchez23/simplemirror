#!/bin/bash
docker-compose up -d mirrorA
docker-compose exec -T mirrorA bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 30"
docker-compose up -d mirrorB
docker-compose up -d webgw
docker-compose ps
