nohup $IRISSYS/ISCAgentUser > $IRISSYS/iscagent_console.log &
sleep 1
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
set sc = ##class(Mirror.Installer).setup("$IRIS_systemname") \
halt
END

