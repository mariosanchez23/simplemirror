#!/bin/bash

dir=$(dirname $0)
pushd $dir

touch CSP.ini
touch CSP.log
touch CSPRT.ini

apacheUser=daemon

chmod 600 CSP.ini
chown $apacheUser CSP.ini
chmod 600 CSP.log
chown $apacheUser CSP.log
chmod 600 CSPRT.ini
chown $apacheUser CSPRT.ini

configName=${CONFIG_NAME-LOCAL}
host=${SERVER_HOST-localhost}
port=${SERVER_PORT-51773}
username=${USERNAME-CSPSystem}
password=${PASSWORD-SYS}

configName2=${CONFIG_NAME2-LOCAL}
host2=${SERVER_HOST2-localhost}
port2=${SERVER_PORT2-51773}

configName3=${CONFIG_NAME3-LOCAL}
host3=${SERVER_HOST3-localhost}
port3=${SERVER_PORT3-51773}

configName4=${CONFIG_NAME4-LOCAL}
host4=${SERVER_HOST4-localhost}
port4=${SERVER_PORT4-51773}

# [SYSTEM]
./cvtcfg setparameter "CSP.ini" "[SYSTEM]" "System_Manager" "*.*.*.*"
# to prevent [Status=Server] connections. WRC #903951
./cvtcfg setparameter "CSP.ini" "[SYSTEM]" "REGISTRY_METHODS" "Disabled"

# [SYSTEM_INDEX]
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "MIRROR" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName2" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName3" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName4" "Enabled"

# [MIRROR]
./cvtcfg setparameter "CSP.ini" "[MIRROR]" "Ip_Address" "$host"
./cvtcfg setparameter "CSP.ini" "[MIRROR]" "TCP_Port" "$port"
./cvtcfg setparameter "CSP.ini" "[MIRROR]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[MIRROR]" "Password" "$password"
./cvtcfg setparameter "CSP.ini" "[MIRROR]" "Mirror_Aware" "1"

# [$configName]
./cvtcfg setparameter "CSP.ini" "[${configName}]" "Ip_Address" "$host"
./cvtcfg setparameter "CSP.ini" "[${configName}]" "TCP_Port" "$port"
./cvtcfg setparameter "CSP.ini" "[${configName}]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[${configName}]" "Password" "$password"

# [$configName2]
./cvtcfg setparameter "CSP.ini" "[${configName2}]" "Ip_Address" "$host2"
./cvtcfg setparameter "CSP.ini" "[${configName2}]" "TCP_Port" "$port2"
./cvtcfg setparameter "CSP.ini" "[${configName2}]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[${configName2}]" "Password" "$password"

# [$configName3]
./cvtcfg setparameter "CSP.ini" "[${configName3}]" "Ip_Address" "$host3"
./cvtcfg setparameter "CSP.ini" "[${configName3}]" "TCP_Port" "$port3"
./cvtcfg setparameter "CSP.ini" "[${configName3}]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[${configName3}]" "Password" "$password"

# [$configName4]
./cvtcfg setparameter "CSP.ini" "[${configName4}]" "Ip_Address" "$host4"
./cvtcfg setparameter "CSP.ini" "[${configName4}]" "TCP_Port" "$port4"
./cvtcfg setparameter "CSP.ini" "[${configName4}]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[${configName4}]" "Password" "$password"

# [APP_PATH_INDEX]
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp/ap1/a" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp/ap1/b" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp/ap2/a" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp/ap2/b" "Enabled"

# [APP_PATH:/]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/]" "Default_Server" "MIRROR"

# [APP_PATH:/csp]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp]" "Default_Server" "MIRROR"
# [APP_PATH:/csp/ap1/a]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp/ap1/a]" "Default_Server" "$configName"
# [APP_PATH:/csp/ap1/b]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp/ap1/b]" "Default_Server" "$configName2"
# [APP_PATH:/csp/ap2/a]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp/ap2/a]" "Default_Server" "$configName3"
# [APP_PATH:/csp/ap2/b]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp/ap2/b]" "Default_Server" "$configName4"

popd

httpd-foreground