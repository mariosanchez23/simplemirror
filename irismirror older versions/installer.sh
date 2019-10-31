/etc/init.d/ISCAgent start
sleep 1
iris session IRIS -U %SYS << done
SuperUser
SYS
do \$SYSTEM.OBJ.Load("/ISC/utiles/Installer.cls", "ck")
set sc = ##class(Mirror.Installer).setup("$IRIS_hostname")
halt
done

