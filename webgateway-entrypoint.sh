#!/bin/bash

dir=$(dirname $0)
pushd $dir

touch CSP.ini
touch CSP.log
touch CSPRT.ini

apacheUser=www-data

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

configName5=${CONFIG_NAME5-LOCAL}
host5=${SERVER_HOST5-localhost}
port5=${SERVER_PORT5-51773}

MirrorConfigName=${MIRROR_CONFIG_NAME-LOCAL}
MirrorConfigName2=${MIRROR_CONFIG_NAME2-LOCAL}


# [SYSTEM]
./cvtcfg setparameter "CSP.ini" "[SYSTEM]" "System_Manager" "*.*.*.*"
# to prevent [Status=Server] connections. WRC #903951
./cvtcfg setparameter "CSP.ini" "[SYSTEM]" "REGISTRY_METHODS" "Disabled"

# [SYSTEM_INDEX]
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$MirrorConfigName" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$MirrorConfigName2" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName2" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName3" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName4" "Enabled"
./cvtcfg setparameter "CSP.ini" "[SYSTEM_INDEX]" "$configName5" "Enabled"

# [$MirrorConfigName]
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName]" "Ip_Address" "$host"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName]" "TCP_Port" "$port"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName]" "Password" "$password"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName]" "Mirror_Aware" "1"

# [$MirrorConfigName2]
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName2]" "Ip_Address" "$host3"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName2]" "TCP_Port" "$port3"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName2]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName2]" "Password" "$password"
./cvtcfg setparameter "CSP.ini" "[$MirrorConfigName2]" "Mirror_Aware" "1"

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

# [$configName5]
./cvtcfg setparameter "CSP.ini" "[${configName5}]" "Ip_Address" "$host5"
./cvtcfg setparameter "CSP.ini" "[${configName5}]" "TCP_Port" "$port5"
./cvtcfg setparameter "CSP.ini" "[${configName5}]" "Username" "$username"
./cvtcfg setparameter "CSP.ini" "[${configName5}]" "Password" "$password"

# [APP_PATH_INDEX]
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/" "Disabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/csp" "Disabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$MirrorConfigName" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$MirrorConfigName2" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$configName" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$configName2" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$configName3" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$configName4" "Enabled"
./cvtcfg setparameter "CSP.ini" "[APP_PATH_INDEX]" "/$configName5" "Enabled"

# [APP_PATH:/]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/]" "Default_Server" "LOCAL"
# [APP_PATH:/csp]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/csp]" "Default_Server" "LOCAL"

# [APP_PATH:/ap1]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$MirrorConfigName]" "Default_Server" "$MirrorConfigName"
# [APP_PATH:/ap2]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$MirrorConfigName2]" "Default_Server" "$MirrorConfigName2"
# [APP_PATH:/ap1a]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$configName]" "Default_Server" "$configName"
# [APP_PATH:/ap1b]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$configName2]" "Default_Server" "$configName2"
# [APP_PATH:/ap2a]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$configName3]" "Default_Server" "$configName3"
# [APP_PATH:/ap2b]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$configName4]" "Default_Server" "$configName4"
# [APP_PATH:/ap2c]
./cvtcfg setparameter "CSP.ini" "[APP_PATH:/$configName5]" "Default_Server" "$configName5"

popd

httpd-foreground