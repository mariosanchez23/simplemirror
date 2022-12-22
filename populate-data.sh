iris session $ISC_PACKAGE_INSTANCENAME -U %SYS << END
set sc = ##class(Mirror.Installer).PopulateMirrorDB() \
halt
END

