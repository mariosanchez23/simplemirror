nohup $IRISSYS/ISCAgentUser > $IRISSYS/iscagent_console.log &
sleep 1
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
do \$SYSTEM.OBJ.Load("/ISC/utiles/Installer.cls", "ck") \
set sc = ##class(Mirror.Installer).setup("$IRIS_systemname") \
halt
END

