#!/bin/bash
chmod -fR 777 iris1A 
chmod -fR 777 iris1B 
chmod -fR 777 iris2A 
chmod -fR 777 iris2B 
chmod -fR 777 iris2C 
# primaries
echo "Staring primaries"
docker-compose up -d ap2a
docker-compose exec -T ap2a bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
# join backups
echo "Staring backups"
docker-compose up -d ap2b
docker-compose exec -T ap2b bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

echo "Staring a reporting"
docker-compose up -d ap2c
docker-compose exec -T ap2c bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"

# defer populate data until mirror cluste is all set.
echo "Populating data"
docker-compose exec -T ap2a bash -c "/ISC/utiles/populate-data.sh"

docker-compose ps
