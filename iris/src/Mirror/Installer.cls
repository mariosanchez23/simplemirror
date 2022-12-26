Include %occInclude

Class Mirror.Installer
{

XData setup [ XMLNamespace = INSTALLER ]
{
<Manifest>
<Var Name="ProductionName" Value="Demo.Production"/>

<Namespace Name="${NAMESPACE}" Create="no">
	<Invoke Class="%SYSTEM.OBJ" Method="ImportDir" CheckStatus="true">
		<Arg Value="${SRCDIR}" />
		<Arg Value="" />
		<Arg Value="ck" />
		<Arg Value=".e" />
		<Arg Value="1" />
	</Invoke>
 	<Production Name="${ProductionName}" AutoStart="1">
	<!-- AutoStart dosen't work -->
	</Production>
</Namespace>
</Manifest>
}

XData setup2 [ XMLNamespace = INSTALLER ]
{
<Manifest>
<Namespace Name="${NAMESPACE}" Create="no">
 	<CSPApplication Url="/csp/${NAMESPACE}" Directory="${CSPDIR}${NAMESPACE}" Resource=""/>
</Namespace>
</Manifest>
}

ClassMethod setup(systemname) As %Status
{
  if $system.Mirror.IsMember() {
		write !,"This system is already configured as a mirror member"
 	}else{
    write !,"Setup for host: "_systemname,!
    
    // Enable mirror: 
    do ..enableMirrorService()

    set mirrorRole=$SYSTEM.Util.GetEnviron("MIRRORROLE")
    if mirrorRole="PRIMARY" {
      do ..createMirror(systemname)
    } else {
      // Allow some time to create mirror in primary
      //h 3
      set primaryAgentAddress=$SYSTEM.Util.GetEnviron("primaryAgentAddress_ip")  //"10.0.1.2"
     
      Set membertype=""
      If mirrorRole="DR" { Set membertype=0}
      ElseIf mirrorRole="REPORTR" { Set membertype=1}
      ElseIf mirrorRole="REPORTRW" { Set membertype=2}
      // "":sync member, 0:async (DR) member, 1:Read-Only Reporting, 2:Read-Write Reporting
      do ..join(membertype,systemname,primaryAgentAddress)
    }
    // Create DB and add it to mirror
    do ..createMirrorDB(mirrorRole)
    }
  quit $$$OK
}

ClassMethod createMirror(systemname) As %Status
{
  set mirrorName="MIRRORSET"
  // Create mirror:
  set MirrorInfo("UseSSL") = 0
  set MirrorInfo("ArbiterNode") = $SYSTEM.Util.GetEnviron("ARBITER_ip")_"|2188" // "10.0.100.10|2188"
  set MirrorInfo("MirrorAddress") = $SYSTEM.Util.GetEnviron("MirrorAddress_ip") //"10.0.1.2"
  set MirrorInfo("ECPAddress") = $SYSTEM.Util.GetEnviron("ECPAddress_ip") // "10.0.100.2"
  ;set MirrorInfo("CompressionForFailoverMembers") = 1 // no compression 
  ;set MirrorInfo("CompressionForAsyncMembers") = 1 // no compression 
  set MirrorInfo("AllowParallelDejournaling") = 2  // all members
  
  set sc = ##class(SYS.Mirror).CreateNewMirrorSet(mirrorName, systemname, .MirrorInfo)
  write !,"Creating mirror "_mirrorName_"..."
  if 'sc do $system.OBJ.DisplayError(sc)  
  quit sc
}

ClassMethod join(membertype, systemname, agentAddress) As %Status
{
  set mirrorName="MIRRORSET"
  set instanceName="IRIS"
  
  // Join as failover:
  If $SYSTEM.Util.GetEnviron("MirrorAddress_ip")'="" {
    set LocalInfo("MirrorAddress") = $SYSTEM.Util.GetEnviron("MirrorAddress_ip") // "10.0.1.3"
  }
  If $SYSTEM.Util.GetEnviron("ECPAddress_ip")'="" {
    set LocalInfo("ECPAddress") = $SYSTEM.Util.GetEnviron("ECPAddress_ip") // "10.0.100.3"
  }
  If (membertype="") {
    s sc=##class(SYS.Mirror).JoinMirrorAsFailoverMember(mirrorName,systemname,instanceName,agentAddress,,.LocalInfo)
  }
  Else {
    s sc=##class(SYS.Mirror).JoinMirrorAsAsyncMember(mirrorName,systemname,instanceName,agentAddress,,membertype,.LocalInfo)  
  }
  write !,"Jonining mirror "_mirrorName_"..."
  if 'sc do $system.OBJ.DisplayError(sc)
  quit sc
}

ClassMethod enableMirrorService() As %Status
{
  do ##class(Security.Services).Get("%Service_Mirror", .svcProps)
  set svcProps("Enabled") = 1
  do ##class(Security.Services).Modify("%Service_Mirror", .svcProps)
  write !,"Enabling mirror service..."
}

ClassMethod createMirrorDB(role) As %Status
{
  set dir="/DB/"
  set dirName="mirrorDB"
  set mirDBName="MIRRORDB"
  set mirrorName="MIRRORSET"
  set mirNSName="MIRRORNS"
  
  write !, "Creating databases and NS "_mirNSName,!
  
  // If no, create it inside of container
  If '##class(%Library.File).Exists(dir) {
    Set dir="/home/irisowner/"
  }

  // Create directory for db
  do ##class(%Library.File).CreateNewDir(dir,dirName)
  // Add DB to config
  set Properties("Directory")=dir_dirName
  do ##class(Config.Databases).Create(mirDBName,.Properties)

  // wait until mirror's ready
  for i=1:1:10 {
    h 1
    set mirrorStatus=$LIST($SYSTEM.Mirror.GetMemberStatus(mirrorName))
    if mirrorStatus="Backup" Quit
    if mirrorStatus="Primary" Quit
    if mirrorStatus="Connected" Quit   // async member
  }
  if ((mirrorStatus'="Primary")&(mirrorStatus'="Backup")&(mirrorStatus'="Connected")) { 
    write "Mirror failed to be ready: Mirror Status:"_mirrorStatus,!
    quit '$$$OK
  }

  Set dbsize=64
  set rc = ##class(SYS.Database).CreateDatabase(dir_dirName,dbsize,,,,,mirDBName,mirrorName)
  if 'rc { 
    write !,"Database creation failed!"
    do $system.OBJ.DisplayError(rc)
    quit rc
  }
  
  // Create namespace for mirrored database
  set ns("Globals")=mirDBName
  set ns("Routines")=mirDBName
  do ##class(Config.Namespaces).Create(mirNSName,.ns)
  set rc = ##class(Config.Namespaces).Exists(mirNSName,.obj,.status)
  if 'rc {
    write !, "NS creation failed."
    do $system.OBJ.DisplayError(rc)
    quit rc
  }
  // Enables production
  Do ##class(%EnsembleMgr).EnableNamespace(mirNSName,0)

  // Add global mappings for BI from MIRRORNS to USER
  Kill props Set props("Database")="MIRRORDB",sc=##Class(Config.MapGlobals).Create("USER","HoleFoods.*",.props)
  Kill props Set props("Database")="MIRRORDB",sc=##Class(Config.MapGlobals).Create("USER","OBJ.DSTIME",.props)

  Set tSC=..EnableWebApps()  //create a web app

  quit $$$OK
}

/// Runs on primary only.
ClassMethod PopulateMirrorDB() As %Status
{
  Set tSC='$$$OK
	Try {
    Set tSC=..CreateProduction()
    $$$ThrowOnError(tSC)
    Set tSC=..BISetup()
    $$$ThrowOnError(tSC)

    New $NAMESPACE
    Set $NAMESPACE="mirrorns" ; ToDo: parameterize it.
    Do ##class(Ens.Director).StartProduction()

	} Catch(e) {
		Set tSC=e.AsStatus()
	}
  Return tSC
}

/// This is a method generator whose code is generated by XGL.
ClassMethod setupMethod(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
    #; Let our XGL document generate code for this method. 
    Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod setupMethod2(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
    #; Let our XGL document generate code for this method. 
    Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup2")
}

ClassMethod CreateProduction(ByRef tVars) As %Status
{
	Set tSC='$$$OK
	Try {
		If '$D(tVars("SRCDIR")) { Set tVars("SRCDIR")="/project" }
		If '$D(tVars("NAMESPACE")) { Set tVars("NAMESPACE")="MIRRORNS" }
		$$$THROWONERROR(tSC,..setupMethod(.tVars))
	} Catch(e) {
		Set tSC=e.AsStatus()
	}
	
  Return tSC
}

ClassMethod EnableWebApps(ByRef tVars) As %Status
{
  New $NAMESPACE
	Set tSC='$$$OK
	Try {
    If '$D(tVars("SRCDIR")) { Set tVars("SRCDIR")="/project" }
    If '$D(tVars("NAMESPACE")) { Set tVars("NAMESPACE")="mirrorns" }
    $$$THROWONERROR(tSC,..setupMethod2(.tVars))

    Set oldns=$NAMESPACE
    Set $NAMESPACE="%SYS"

    Set webapp="/csp/"_tVars("NAMESPACE")_"/api/"
    Set tSC = ##Class(Security.Applications).Create(webapp)
    Set tSC = ##Class(Security.Applications).Get(webapp,.props)
    $$$ThrowOnError(tSC)
    Set props("DispatchClass")="MyApp.disp"
    Set props("Resource")=""
    Set props("MatchRoles")=":%All"
    Set props("NameSpace")=tVars("NAMESPACE")
    Kill props("Type")
    Set tSC = ##Class(Security.Applications).Modify(webapp,.props)
    $$$ThrowOnError(tSC)

    #; accept mutiple names as application path, such as "ap1, ap1a".
    #; See https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GCGI_remote_csp#GCGI_change_server_name
    Do $System.CSP.SetConfig("CSPConfigName",$SYSTEM.Util.GetEnviron("CSPConfigName"))
	  Set $NAMESPACE=oldns
	} Catch(e) {
		Set tSC=e.AsStatus()
	}
	
  Return tSC
}

ClassMethod BISetup(ByRef tVars) As %Status
{
	Set tSC='$$$OK
	Try {
		If '$D(tVars("NAMESPACE")) { Set tVars("NAMESPACE")="mirrorns" }

	Set oldns=$NAMESPACE
	New $NAMESPACE

	#; Don't import Cube related classes here because this db is on a primary server
	Set $NAMESPACE=tVars("NAMESPACE")
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Region.cls","ck") 
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Country.cls","ck") 
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Outlet.cls","ck") 
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Product.cls","ck") 
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Transaction.cls","ck") 
  // will report compile error but it works
  w "++You can ignore compile erros here++",!
  Set tSC=$SYSTEM.OBJ.Load("/home/irisowner/Samples-BI/src/cls/HoleFoods/Utils.cls","ck") 
	Do ##class(HoleFoods.Utils).BuildData(1000,0,1)
  w "--You can ignore compile erros here--",!

	Set $NAMESPACE=oldns

	} Catch(e) {
		Set tSC=e.AsStatus()
	}
  	Return tSC
}

}
