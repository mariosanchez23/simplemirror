nohup $IRISSYS/ISCAgentUser start &>/dev/null &
sleep 1
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
do \$SYSTEM.OBJ.Load("/install/Installer.cls", "ck") \
set sc = ##class(Mirror.Installer).setup("$IRIS_hostname","$IRIS_mirrorname","$IRIS_arbitername") \
halt
END

