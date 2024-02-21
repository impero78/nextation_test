#!/bin/bash

#SESSION_1_TYPE=chromium
#SESSION_1_CHROMIUM_SERVER=http://google.com

# Process the SESSION_*_ commands
for ((i = 0; i <= 9; i++)); do
    session_type_varname=SESSION_${i}_TYPE
    session_type=${!session_type_varname}
    session_autostart_varname=SESSION_${i}_AUTOSTART
    session_autostart=${!session_autostart_varname}
    if [ -n "$session_type" ]; then
            echo "Found $session_type_varname = $session_type"	    
	    session_server_varname=SESSION_${i}_${session_type^^}_SERVER
	    session_server=${!session_server_varname}
    	    echo "Found $session_server_varname = $session_server"
    	    session_options_varname=SESSION_${i}_${session_type^^}_OPTIONS
    	    session_options=${!session_options_varname}
	    echo "Found $session_options_varname = $session_options"
	    echo "Xterm params = $session_type $session_server $session_options"
            xterm -e `$session_type $session_server` &
	fi



done
