Class MyInstallerPackage.Installer
{

ClassMethod setup(ByRef tVars) As %Status
{
	New $NAMESPACE
	Set tSC='$$$OK
	Try {

		Set oldns=$NAMESPACE

		Set $NAMESPACE="USER"
		Set tSC=$SYSTEM.OBJ.LoadDir("/home/irisowner/Samples-BI/src","ck",,1)

		Set $NAMESPACE="%SYS"
		; enable BI
		Set webapp="/csp/user"
		Set tSC = ##Class(Security.Applications).Get(webapp,.props)
		Set props("DeepSeeEnabled")=1
		Set tSC = ##Class(Security.Applications).Modify(webapp,.props)
		$$$ThrowOnError(tSC)
		Set $NAMESPACE=oldns

	} Catch(e) {
		Set tSC=e.AsStatus()
	}
  	Return tSC
}

}
