iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
do \$SYSTEM.OBJ.Load("/ISC/utiles/MirrorPopulate.cls", "ck") \
set sc = ##class(Mirror.Populate).PopulateMirrorDB() \
halt
END

