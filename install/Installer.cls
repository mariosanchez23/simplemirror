Include %occInclude

Class Mirror.Installer
{

ClassMethod setup(hostname,pMirrorName as %String = "MIRRORSET",pArbiterName as %String="arbiter",pDebug as %Boolean=0) As %Status
{
  // For demos - avoid the need to set a new password in first login
  do ##class(Security.Users).UnExpireUserPasswords("*")

  if $system.Mirror.IsMember() 
  {
		write !,"This system is already configured as a mirror member"
 	}
  else
  {
    write !,"Setup for host: "_hostname,!   
    // Enable mirror: 
    do ..enableMirrorService()
    if hostname="serverA" 
    {
      do ..createMirror("serverA",pMirrorName,pArbiterName)
    } 
    else 
    {
      h 5 ///Give additional time for serverA start up
      do ..joinAsFailover("serverB","serverA",pMirrorName)
    }

    // Allow some time to create mirror before creating DDBB
    for i=1:1:20 
    {
      h 1
      set mirrorSt=$LIST($SYSTEM.Mirror.GetMemberStatus(pMirrorName))
      set:pDebug ^dbgFlag(hostname,"loop",$I(^dbgFlag))=mirrorSt
      quit:$case(mirrorSt,"Backup":1,"Primary":1,"Connected":1,:0)
    }

    // Whatever status distinct to Backup, Primary or Connected is considered a failure
    if '$case(mirrorSt,"Backup":1,"Primary":1,"Connected":1,:0)
    {
      write "Mirror "_pMirrorName_" failed to be ready: Mirror Status:"_mirrorSt,!
      quit '$$$OK
    }
    // Create DB and add it to mirror  
    do ..createMirrorDB(pMirrorName)
  }
  quit $$$OK
}

ClassMethod createMirror(hostname, pMirrorName as %String="MIRRORSET", pArbiterName as %String="arbiter",pDebug as %Boolean=0) As %Status
{
  // Create mirror:
  set mirror("UseSSL") = 0
  set mirror("ArbiterNode") = pArbiterName_"|2188"
  set sc = ##class(SYS.Mirror).CreateNewMirrorSet(pMirrorName, hostname, .mirror)
  set:pDebug ^dbgFlag(hostname,"createMirror")=sc
  write !,"Creating mirror "_pMirrorName_"..."

  if 'sc do $system.OBJ.DisplayError(sc)  
  quit sc
}

ClassMethod joinAsFailover(hostnameFrom, hostnameTo, pMirrorName as %String="MIRRORSET",pDebug as %Boolean=0) As %Status
{
  set instanceName="IRIS"
  // Join as failover:
  s sc=##class(SYS.Mirror).JoinMirrorAsFailoverMember(pMirrorName,hostnameFrom,instanceName,hostnameTo,,.MirrorInfo)
  set:pDebug ^dbgFlag(hostnameFrom,"joinAsFailover")=sc
  write !,"Jonining mirror "_pMirrorName_"..."
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

ClassMethod createMirrorDB(pMirrorName as %String="MIRRORSET",pDebug as %Boolean=0) As %Status
{
  set dir = $system.Util.InstallDirectory()_"/mgr/"
  set:pDebug ^dbgFlag("createMirrorDB","dir")=dir
  set dirName="mirrorDB"
  set mirDBName="MIRRORDB"
  set mirNSName="MIRRORNS"
  
  write !, "Creating databases and NS "_mirNSName
  
  // Create the directory
  do ##class(%Library.File).CreateNewDir(dir,dirName)
  // Add DB to config
  // Set the DB properties
  set Properties("Directory")=dir_dirName
  do ##class(Config.Databases).Create(mirDBName,.Properties)
 
  set sc = ##class(SYS.Database).CreateDatabase(dir_dirName,,,,,,mirDBName,pMirrorName)
  set:pDebug ^dbgFlag("createMirrorDB","status CreateDatabase")=sc
 
  if 'sc { 
    write !,"Database creation failed!"
    do $system.OBJ.DisplayError(sc)
    quit sc
  }
  
  // Create namespace for mirrored database
  set ns("Globals")=mirDBName
  set ns("Routines")=mirDBName
  set sc =##class(Config.Namespaces).Create(mirNSName,.ns)
  set:pDebug ^dbgFlag("createMirrorNS","status CreateMirrorNS")=sc

  if 'sc {
    write !, "NS creation failed."
    do $system.OBJ.DisplayError(sc)
    quit sc
  }
    
  quit $$$OK
}

}
