nohup $IRISSYS/ISCAgentUser start &>/dev/null &
sleep 1
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
do \$SYSTEM.OBJ.Load("/ISC/utiles/Installer.cls", "ck") \
set sc = ##class(Mirror.Installer).setup("$IRIS_hostname") \
halt
END

