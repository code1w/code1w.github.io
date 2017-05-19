#!/bin/sh

/usr/bin/osascript <<END
tell application "iTerm"
    -- make a new terminal
    set myterm to (make new terminal)
    
    -- talk to the new terminal
    tell myterm
        
        -- make a new session
        set mysession to (make new session at the end of sessions)
        
        -- talk to the session
        tell mysession
            
            -- set some attributes
            set name to "$1"
            -- set foreground color to "red"
            set background color to {0, 11111, 11111}
            set transparency to "0.1"
            
			activate

            -- execute a command
            exec command "/bin/bash -c \"cd `pwd`; $2; read -n1 -rsp 'press any key to continue...'\""
            

        end tell -- we are done talking to the session
        
    end tell
end tell
END


