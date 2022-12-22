Include %occInclude

Class Mirror.Installer
{

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
     
      If mirrorRole="REPORT" { Set membertype=2}
      Else { Set membertype="" } 
      // "":sync member, 0:async (DR) member, 1:Read-Only Reporting, 2:Read-Write Reporting
      do ..join(membertype,systemname,primaryAgentAddress)
    }
    // Create DB and add it to mirror
    do ..createMirrorDB()
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
  set LocalInfo("MirrorAddress") = $SYSTEM.Util.GetEnviron("MirrorAddress_ip") // "10.0.1.3"
  set LocalInfo("ECPAddress") = $SYSTEM.Util.GetEnviron("ECPAddress_ip") // "10.0.100.3"
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

ClassMethod createMirrorDB() As %Status
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
    
  Set tSC=$SYSTEM.OBJ.ImportDir("/project/MyInstallerPackage","","ck",.e,1)
  Set tSC=##class(MyInstallerPackage.Installer).EnableWebApps()  //create a web app

  quit $$$OK
}

ClassMethod PopulateMirrorDB() As %Status
{
  Set tSC='$$$OK
	Try {
    Set tSC=##class(MyInstallerPackage.Installer).CreateProduction()
    $$$ThrowOnError(tSC)
    Set tSC=##class(MyInstallerPackage.Installer).BISetup()
    $$$ThrowOnError(tSC)

    New $NAMESPACE
    Set $NAMESPACE="mirrorns" ; ToDo: parameterize it.
    Do ##class(Ens.Director).StartProduction()

	} Catch(e) {
		Set tSC=e.AsStatus()
	}
  Return tSC
}

}
