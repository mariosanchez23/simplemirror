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
  
    if systemname="mirrorA" {
      do ..createMirror(systemname)
    } else {
      // Allow some time to create mirror in primary
      //h 3
      set primaryAgentAddress=$SYSTEM.Util.GetEnviron("primaryAgentAddress_ip")  //"10.0.1.2"
      do ..joinAsFailover(systemname,primaryAgentAddress)
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
  set sc = ##class(SYS.Mirror).CreateNewMirrorSet(mirrorName, systemname, .MirrorInfo)
  write !,"Creating mirror "_mirrorName_"..."
  if 'sc do $system.OBJ.DisplayError(sc)  
  quit sc
}

ClassMethod joinAsFailover(systemname, agentAddress) As %Status
{
  set mirrorName="MIRRORSET"
  set instanceName="IRIS"
  
  // Join as failover:
  set LocalInfo("MirrorAddress") = $SYSTEM.Util.GetEnviron("MirrorAddress_ip") // "10.0.1.3"
  set LocalInfo("ECPAddress") = $SYSTEM.Util.GetEnviron("ECPAddress_ip") // "10.0.100.3"
  s sc=##class(SYS.Mirror).JoinMirrorAsFailoverMember(mirrorName,systemname,instanceName,agentAddress,,.LocalInfo)
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
  set dir="/ISC/"
  set dirName="mirrorDB"
  set mirDBName="MIRRORDB"
  set mirrorName="MIRRORSET"
  set mirNSName="MIRRORNS"
  
  write !, "Creating databases and NS "_mirNSName
  
  // Create the directory
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
  }
  if ((mirrorStatus'="Primary")&(mirrorStatus'="Backup")) { 
    write "Mirror failed to be ready: Mirror Status:"_mirrorStatus,!
    quit '$$$OK
  }

  set rc = ##class(SYS.Database).CreateDatabase(dir_dirName,,,,,,mirDBName,mirrorName)
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
  Do ##class(%EnsembleMgr).EnableNamespace(mirNSName,0)
    
  if (mirrorStatus="Primary") {
    Set tSC=$SYSTEM.OBJ.ImportDir("/project/MyInstallerPackage","","ck",.e,1)
    Set tSC=##class(MyInstallerPackage.Installer).setup()
    Set $NAMESPACE=mirNSName
    Do ##class(Ens.Director).StartProduction()    
  }

  quit $$$OK
}

}
