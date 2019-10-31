Include %occInclude

Class Mirror.Installer
{

ClassMethod setup(hostname) As %Status
{
  if $system.Mirror.IsMember() {
		write !,"This system is already configured as a mirror member"
 	}else{
    write !,"Setup for host: "_hostname,!
    
    // Enable mirror: 
    do ..enableMirrorService()
  
    if hostname="mirrorA" {
      do ..createMirror("mirrorA")
    } else {
      // Allow some time to create mirror in primary
      h 2
      do ..joinAsFailover("mirrorB","mirrorA")
    }
    // Create DB and add it to mirror
    do ..createMirrorDB()
    }
  quit $$$OK
}

ClassMethod createMirror(hostname) As %Status
{
  set mirrorName="MIRRORSET"
  // Create mirror:
  set mirror("UseSSL") = 0
  set sc = ##class(SYS.Mirror).CreateNewMirrorSet(mirrorName, hostname, .mirror)
  write !,"Creating mirror "_mirrorName_"..."
  if 'sc do $system.OBJ.DisplayError(sc)  
  quit sc
}

ClassMethod joinAsFailover(hostnameFrom, hostnameTo) As %Status
{
  set mirrorName="MIRRORSET"
  set instanceName="IRIS"
  
  // Join as failover:
  s sc=##class(SYS.Mirror).JoinMirrorAsFailoverMember(mirrorName,hostnameFrom,instanceName,hostnameTo,,.MirrorInfo)
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
  // Set the DB properties
  set Properties("Directory")=dir_dirName
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
    
  quit $$$OK
}

}
