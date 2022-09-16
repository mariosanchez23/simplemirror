Include %occInclude

Class Mirror.Installer
{

ClassMethod setup(hostname,pMirrorName as %String = "MIRRORSET",pArbiterName as %String="arbiter") As %Status
{
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
      do ..joinAsFailover("serverB","serverA",pMirrorName)
    }

    // Allow some time to create mirror before creating DDBB
    for i=1:1:10 
    {
      h 1
      set mirrorSt=$LIST($SYSTEM.Mirror.GetMemberStatus(pMirrorName))
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

ClassMethod createMirror(hostname, pMirrorName as %String="MIRRORSET", pArbiterName as %String="arbiter") As %Status
{
  // Create mirror:
  set mirror("UseSSL") = 0
  set mirror("ArbiterNode") = pArbiterName_"|2188"
  set sc = ##class(SYS.Mirror).CreateNewMirrorSet(pMirrorName, hostname, .mirror)
  write !,"Creating mirror "_pMirrorName_"..."

  if 'sc do $system.OBJ.DisplayError(sc)  
  quit sc
}

ClassMethod joinAsFailover(hostnameFrom, hostnameTo, pMirrorName as %String="MIRRORSET") As %Status
{
  set instanceName="IRIS"
  // Join as failover:
  s sc=##class(SYS.Mirror).JoinMirrorAsFailoverMember(pMirrorName,hostnameFrom,instanceName,hostnameTo,,.MirrorInfo)
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

ClassMethod createMirrorDB(pMirrorName as %String="MIRRORSET") As %Status
{
  //set dir="/ISC/"
  set dir = $system.Util.InstallDirectory()_"/mgr/"
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
 
  set rc = ##class(SYS.Database).CreateDatabase(dir_dirName,,,,,,mirDBName,pMirrorName)
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
    
  quit $$$OK
}

}
