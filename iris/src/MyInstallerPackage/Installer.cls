Class MyInstallerPackage.Installer
{

ClassMethod setup(ByRef tVars) As %Status
{
	New $NAMESPACE
	Set tSC='$$$OK
	Try {

		Set oldns=$NAMESPACE

		Set $NAMESPACE="USER"
		; for simple rest api
		Set tSC=$SYSTEM.OBJ.LoadDir("/home/irisowner/src/MyApp","ck",,1)
		; to populate HoleFoods Cubes
		Set tSC=$SYSTEM.OBJ.LoadDir("/home/irisowner/Samples-BI/src","ck",,1)

		Set $NAMESPACE="%SYS"
		; for simple rest api
		Set tSC = ##Class(Security.Applications).Get("/csp/user",.props)
		$$$ThrowOnError(tSC)
		Set props("DispatchClass")="MyApp.disp"
		Set props("Resource")=""
		Set props("DeepSeeEnabled")=0
		Set props("MatchRoles")=":%All"
		Kill props("Type")
		Set tSC = ##Class(Security.Applications).Create("/csp/user/api",.props)
		$$$ThrowOnError(tSC)		

		; enable BI
		Set webapp="/csp/user"
		Set tSC = ##Class(Security.Applications).Get(webapp,.props)
		Set props("DeepSeeEnabled")=1
		Set tSC = ##Class(Security.Applications).Modify(webapp,.props)
		$$$ThrowOnError(tSC)
		Set $NAMESPACE=oldns

	} Catch(e) {
		Set tSC=e.AsStatus()
		zw tSC
	}
  	Return tSC
}

}
