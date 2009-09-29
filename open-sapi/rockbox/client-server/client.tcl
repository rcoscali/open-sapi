#!/usr/bin/tclsh
#******************************************************************************
#             __________               __   ___.
#   Open      \______   \ ____   ____ |  | _\_ |__   _______  ___
#   Source     |       _//  _ \_/ ___\|  |/ /| __ \ /  _ \  \/  /
#   Jukebox    |    |   (  <_> )  \___|    < | \_\ (  <_> > <  <
#   Firmware   |____|_  /\____/ \___  >__|_ \|___  /\____/__/\_ \
#                     \/            \/     \/    \/            \/
#
#   Copyright (C) 2007 by Thomas Lloyd
#
# All files in this archive are subject to the GNU General Public License.
# See the file COPYING in the source tree root for full license agreement.
#
# This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
# KIND, either express or implied.
#
#******************************************************************************

# ------------------------------------------------------------------------------
#Application Name: Open SAPI Clip Generator v0.1 Alpha for Rockbox Utulity
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ProcName : helpMe
# Usage    : Supplies the user with usage information when called through stdout
# Accepts  : None
# Returns  : None
# Called By: Main
#-------------------------------------------------------------------------------
proc helpMe {} {
   
   puts "Open SAPI Clip Generator v0.1 Alpha for Rockbox Utulity\n"

   puts "Usage: opensapi-cli ...\[swithches\] -ehlortv -t \"message\" @@ "
   puts "Platform independant command line interface to the Microsoft Speech \
   Engine\n"
   
   puts "Switches:"
   puts "\t -o <dir/filename.ext>  : Location & filename of output file"
   puts "\t -t, --text <text>      : Text to be spoken terminate with <space>@@"
   puts "\t -l, --volume ?<value>? : Gets/Sets Volume Level. Range Min 0 - 100 Max"
   puts "\t -r, --rate  ?<value>?  : Gets/Sets Speech Rate. Range Min -10 - 10 Max"
   puts "\t --pitch ?<value>?      : Gets/Sets Speech Pitch. Range Min -10 - 10 Max"
   puts "\t --wavformat ?<value>?  : Gets/Sets Output Wav Format"

   puts "\t -e, --engine ?<value>? : Gets/Sets Default Engine"
#  puts "\t -d, --device <value>   : Sets Audio Device"
#  puts "\t -x, --noxml            : Turns on XML markup processing"
#  puts "\t --xml-global           : Enable XML markup globally"
#  puts "\t -i, --icon <file>      : Sound Icon to play"
#  puts "\t -a, --async            : Ayncronous Playback"
#  puts "\t     --purge            : Remove & replace all queued speech"
#  puts "\t -c, --config <file>    : Specify configuration file"
#  puts "\t -o, --save <file>      : Output current config to file"
#  puts "\t -s, --server <action>  : Server Actions - start, restart, stop"
   puts "\t --port <value>         : Value for server port. Default 5491"
#  puts "\t --test                 : Tests components are present and configured"
   puts "\t --killserver           : Forces server to quit if timeout disbabled"
   puts "\t -v, --verbose          : Verbose output"
#  puts "\t --pipemode             : Pipemode takes input on stdin to speak"
   puts "\t -h, --help             : This message\n"
   
   puts "For updates, guides and help please see: http://www.rockbox.org"
   puts "For bugs, comments and support please contact thomaslloyd@yahoo.com." 
}
# ------------------------------------------------------------------------------
# ProcName : bugMe  
# Usage    : If verbose output is on this function will output debug info to
#          : stdout or logfile
# Accepts  : $message to be output
# Returns  : None
# Called By: Any debug statement
#-------------------------------------------------------------------------------
proc bugMe {message} {
 
 global verboseText

    if {$verboseText} { puts stderr "Client : $message" }

}
#-------------------------------------------------------------------------------
# ProcName : startUpSever 
# Usage    :  
#          : 
# Accepts  :
# Returns  :
# Called By:
#-------------------------------------------------------------------------------
proc startUpSever { port } {

set attempt 0
set app ""
set appPath ""
set script ""
set os [split $::tcl_platform(os) " "]
set appName osapi-srv.exe
set nullDevice NUL
set appLocation [info nameofexecutable]


    # Wine is not installed = POSIX ENOENT {no such file or directory}
    # Wine is installed, run without a program = CHILDSTATUS 19456 1
    # Wine is installed, run with --version = Normal Exit
    # Wine Cannot run/find the given program = CHILDSTATUS 19487 126
    # Wine Exits Normally = NONE
    
    # Implement Code to check which OS we are running on
      bugMe "Attempting Server Start Up"
    
    # Test that wine is installed on everything other than Windows
    if {[lindex $os 0] != "Windows" } {
        set app "wine"
        if { [catch {exec wine --version} msg] } {
            puts stderr "Wine Test...........FAILED"
            puts stderr "Please check that wine is properly installed and try \
            again"
            exit
        } else {
            bugMe "Wine Test...............OK"
            set nullDevice "/dev/null"       
        }
    }
    
    # Test in Path
    if { [catch {exec $appName --version 2> $nullDevice} msg ] } { 
        if { [catch {exec wine $appName --version 2> $nullDevice} msg ] } {
            bugMe "Unable to locate server in PATH"
            set pathCheck 1 
        } else {
        # Command Runs OK
        bugMe "Server Located PATH......OK" 
        set pathCheck 0
        }   
    } else {
    # Command Runs OK
    bugMe "Server Located PATH......OK"
    set pathCheck 0
    }
    
  #   puts $msg  
  #   puts $::errorInfo
  #   puts $::errorCode
  
    # Test in pwd and same path as client
    
    
    # Local dir check
    if { $pathCheck } {
        
        if { [file exists "[pwd]/$appName"] } {
            if { [file executable "[pwd]/$appName"] } {
                set appPath "[pwd]/$appName"
                bugMe "Server Located PWD......OK" 
            } else {
                puts stderr "Server found PWD. Unable to exectue!\
                Please check user/file permissions"
                exit 1
            }
        } else {
            bugMe "Unable to locate server in PWD"
            if { [file exists "$appLocation/$appName"] } {
                if { [file executable "$appLocation/$appName"] } {
                    set appPath "$appLocation/$appName"
                    bugMe "Server Located CliPATH..OK" 
                } else {
                    puts stderr "Server found in Client PATH. Unable to exectue!\
                    Please check user/file permissions"
                }
            } else {
                bugMe "Unable to locate server in Client PATH"
            }
        }
    }
    
    if {$appPath == ""} {
    #Code used when in testng enivroment
        if { [file exists $::env(HOME)/open-sapi/tools/tcl/bin/tclsh85.exe] &&\
        [file exists $::env(HOME)/open-sapi/rockbox/client-server/server.tcl] } {
            set appPath "$::env(HOME)/open-sapi/tools/tcl/bin/tclsh85.exe"
            set script "$::env(HOME)/open-sapi/rockbox/client-server/server.tcl"
            bugMe "Server Location.........OK"
        } else {
        puts stderr "Server Location.....FAILED"
        puts stderr "Failed to locate Server Binary. See verbose output for more"
        exit 1
        }
    }
    
# Run the Server 
    if { [catch {exec $app $appPath $script --port $port 2> $nullDevice &} msg ] } {
         bugMe "Server Startup......FAILED"
         puts $msg  
         puts $::errorInfo
         puts $::errorCode 
         exit
    } else {
        bugMe "Server Startup..........OK"
    }

#When the file is located and executed wait for the server to become ready.
    while { $attempt <= 6 } {  
        if { [catch {set sock [socket localhost $port] } err] } {
            after 10000
            incr attempt
            bugMe "Attempt No. $attempt"  
        } else {
            return $sock
        }
    }    
puts stderr "Client : Critical Error - unable to start Server on port:$port"
exit
}
#-------------------------------------------------------------------------------
# ProcName : sapiRead  
# Usage    : 
# Accepts  :
# Returns  :
# Called By:
#-------------------------------------------------------------------------------
proc sapiRead { sock } {
 
 global readyCheckerID
 set outChannel "stdout"
 set processedMessage ""
 set skip 0 

   if { [gets $sock message] == -1 || [eof $sock] } {
        bugMe "Server closing client:socket closed"
        catch {flush $sock} err2
        catch {close $sock} err
        exit
   } else {    
       set message [split $message ":"]
       set x 0    
       foreach element $message {
           if { !$skip } {
               switch -exact -- $element {
                   
                   100 { # Trying
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                    }
                   
                   101 { # Trying Synth
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   102 { # Trying Setting
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                    }
                   
                   103 { # Trying Test 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   200 { # OK 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   201 { # Synthesis OK
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       catch {close $sock} err
                       exit
                       set skip 1
                   }
                   
                   202 { # Setting OK 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set formatDesc [lindex $message [expr $x + 2] ]
                       bugMe "Response - $element - $codeDesc - $formatDesc"
                       puts stdout "$element:$formatDesc"
                       set skip 2
                   }
                   
                   204 { # Server Ready
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       
                       foreach event $readyCheckerID {
                         # bugMe "Response - Cancelling Ready Test Event: \
                           $event"
                           after cancel $event
                       }
                       
                       processCommands $sock
                       set skip 1
                   }
                   
                   296 { # Rate
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set rateVal [lindex $message [expr $x + 2] ]
                       bugMe "Response - $element - $codeDesc:$rateVal"
                       puts stdout "$element:$rateVal"
                       set skip 2
                   }
                   
                   297 { # Voice List
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set vID [lindex $message [expr $x + 2] ]
                       set vName [lindex $message [expr $x + 3] ]
                       set vGender [lindex $message [expr $x + 4] ]
                       bugMe "Response - $element - $codeDesc: $vID:$vName:$vGender"
                       puts stdout "$element:$vID:$vName:$vGender"
                       set skip 4
                   }
                   
                   298 { # Format List 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set formatNo [lindex $message [expr $x + 2] ]
                       set formatDesc [lindex $message [expr $x + 3] ]
                       bugMe "Response - $element - $codeDesc:\
                       $formatNo.$formatDesc"
                       puts stdout "$element:$formatNo:$formatDesc"
                       set skip 3
                   }
                   
                   299 { # Shutdown OK 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   400 { # Bad Request 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   500 { # Server Internal Error 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   501 { # Not Implemented 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   504 { # Time Out 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   513 { # Message Too Large 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   590 { # COM error
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   593 { # Unsupported Wav Format 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set formatDesc [lindex $message [expr $x + 2] ]
                       bugMe "Response - $element - $codeDesc - $formatDesc"
                       set skip 2
                   }
                   
                   594 { # No Speech Engines Match that Request 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       set engineNo [lindex $message [expr $x + 2] ]
                       bugMe "Response - $element - $codeDesc No.$engineNo"
                       set skip 2
                   }
                   
                   595 { # Shutdown Failure 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   596 { # Startup Failure 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   597 { # Server Port Busy 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   598 { # MS Visual C++ DLL Failure 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   599 { # Unable to Initalise SAPI 
                       set codeDesc [lindex $message [expr $x + 1] ]
                       bugMe "Response - $element - $codeDesc"
                       set skip 1
                   }
                   
                   default {
                       if {$element != ""} { 
                           bugMe "STDOUT - $element"
                           set processedMessage "$processedMessage $element"
                       }
                   }
               }; # End of Switch
           } else { set skip [expr $skip - 1] }; # End of IF
       incr x
       }; # End of Foreach
       set processedMessage [string trimleft $processedMessage]

# Bug: Never identified but the server socket would pass a \n to the client 
#      causing problem unless handeled.

       if { [string len $processedMessage] } {
           puts $outChannel "$processedMessage"
       }
   }      
}
#------------------------------------------------------------------------------
# ProcName : processCommands
# Usage    : 
# Accepts  :
# Returns  :
# Called By:
#-------------------------------------------------------------------------------
proc processCommands { sock } {
 global argv argc
 
 set textPending 0
 set runTest 0
 set skip 0
 set flag 0
 set filename "[pwd]/sapi.wav"
 set x 0
 set pitch 0
 set volume 100
 set rate 0
 set command ""
 set text ""
 set wavFormat 22
 set port 5491
 set attempt 0

 bugMe "Beginning of Argument Processing"
foreach element $argv {
    bugMe "Arg = $element"
        if {$skip == 0} {
            switch -exact -- $element {
	        
                --killserver {
                    set command "$command killServer" 
                }
                
                --wavformat {
                    set format [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $format == "?" || $1stChar == "-" || $1stChar == "" } { 
                    set command "$command getFormat" 
                    } else {
                    set command "$command setFormat $format"
                    }
                    
                set skip 1
                }
                
                -f {
                    set feedbackLvl [lindex $argv [expr $x + 1] ]
                    bugMe "Feeback Level : $feedbackLvl"
                    set command "$command setFeedback $feedbackLvl"
                    set skip 1
                }
                
                -o {
                    set filename [lindex $argv [expr $x + 1] ]
                    bugMe "Filename Set : $filename"
                    set skip 1
                }
                
                -a {
                    set flag [expr $flag | 1]
                    bugMe "Async Mode" 
                }

                --async {
                    set flag [expr $flag | 1]
                    bugMe "Async Mode"
                }      
	          
	             -l {
                    # Requires a regexpression to check for valid input here 
                    set volume [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $volume == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getVol"
                        bugMe "Current Volume: $volume" 
                    } else {
                        if { $volume < 0 } {
                            set volume 0
                            bugMe "Volume Range 0-100. Negative value detected, correcting to min 0"
                        }
                        if { $volume > 100 } { 
                            set volume 100
                            bugMe "Volume Range 0-100. Value too high, correcting to max 100"
                        }
                        #Process XML Later
                        bugMe "Volume Set: $volume"
                    }
	                 set skip 1
                }

                --volume {
                    # Requires a regexpression to check for valid input here 
                    set volume [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $volume == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getVol"
                        bugMe "Current Volume: $volume " 
                    } else {
                        if { $volume < 0 } {
                            set volume 0
                            bugMe "Volume too low, correcting to min 0"
                        }
                        if { $volume > 100 } { 
                            set volume 100
                            bugMe "Volume too high, correcting to max 100"
                        }
                        #Process XML Later
                        bugMe "Volume Set: $volume"
                    }
	                 set skip 1
                }
              
                -e {
                    # Requires a regexpression to check for valid input here
                    set engineNum [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $engineNum == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getEngine"
                        bugMe "Got Engine List"  
                    } else {
                        set command "$command setEngine $engineNum"
                    }  
	                 set skip 1
                }

                --engine {
                    # Requires a regexpression to check for valid input here
                    set engineNum [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $engineNum == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getEngine"
                        bugMe "Got Engine List"  
                    } else {
                        set command "$command setEngine $engineNum"
                    }  
	                 set skip 1
                }
                
	             -r {
                    # Sanity check Requires a regexpression
                    set rate [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $rate == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getRate" 
                        bugMe "Current Rate: $rate"
                    } else {
                        if { $rate < -10 } { set rate -10
                            bugMe "Rate too low, correcting to min 0"
                        }
                        if { $rate > 10 } { set rate 10
                            bugMe "Rate too high, correcting to max 10"
                        }
                        #Process XML Later
                        bugMe "Set Rate: $rate"
                    }
                    set skip 1           
                }

                --rate {
                    # Sanity check Requires a regexpression
                    set rate [lindex $argv [expr $x + 1] ]
                    set 1stChar [string index [lindex $argv [expr $x + 1] ] 0]
                    if { $rate == "?" || $1stChar == "-" || $1stChar == ""} {
                        set command "$command getRate" 
                        bugMe "Current Rate: $rate"
                    } else {
                        if { $rate < -10 } { set rate -10
                            bugMe "Rate too low, correcting to min 0"
                        }
                        if { $rate > 10 } { set rate 10
                            bugMe "Rate too high, correcting to max 10"
                        }
                        #Process XML Later
                        bugMe "Set Rate: $rate"
                    }
                    set skip 1    
                }

	             -t {
	                 set i 1
	                 set textPending 1
	                 set word [lindex $argv [expr $x + $i]]
	                 set text $word
	                 incr i
	                 while {$word != "@@"} {
	                     set word [lindex $argv [expr $x + $i]]
	                         if {$word != "@@"} {
	                             set text "$text $word"   
	                         }
	                 incr i
	                 }
	                 bugMe "Speak: $text"
	                 set skip [expr $i - 1]
                }

                --text {
                    set i 1
                    set textPending 1
	                 set word [lindex $argv [expr $x + $i]]
	                 set text $word
	                 incr i
	                 while {$word != "@@" ||} {
	                     set word [lindex $argv [expr $x + $i]]
	                     set text "$text $word"
	                     incr i
	                 }
	                 bugMe "Client: Send for speech  - $text"
	                 set skip [expr $i - 1]
                }

	             -x {
                    set flag [expr $flag | 8]
                    bugMe "Client: Speech Flag: $flag - XML" 
                }

                --xml {
                    set flag [expr $flag | 8]
                    bugMe "Client: Speech Flag: $flag - XML"  
                }

                --notxml {
                    set flag [expr $flag | 16]
                    bugMe "Client: Speech Flag: $flag - not XML"  
                }
                
                --pitch {
                    set pitch [lindex $argv [expr $x + 1] ]
                    #Process XML Later
                    bugMe "Set Pitch: $pitch"
                    set skip 1
                }
                
                -v {}
                
                --verbose {}
                
                --port { set skip 1 }
                
                default {
                    puts stderr "Unknown commandline switch $element.\
                     Please type -h for usage help"
                }
         	
            } ; # End switch
        } else { set skip [expr $skip - 1]} ; # End if skip
    incr x
    };# End of foreach    
     bugMe "End of Prcessing"
    
    set command "$command speechFlag $flag"
    set command [string trimleft $command]
    bugMe "Sending - $command"
    
    puts $sock $command
    
    if {$volume != "?"} {
        set text "<volume level=\"$volume\"/> $text"
    }
    if {$pitch != "?"} {
        set text "<pitch absmiddle=\"$pitch\"/> $text"
    }
    if {$rate != "?"} {
        set text "<rate absspeed=\"$rate\"/> $text"
    }
     
    if {$runTest} {
        if {$textPending} {
            bugMe "Error: Testing overrides text output remove --test option"
        } 
        puts $sock "testMe This is a test of the rockbox Utility speech output."
        
     } else {
         if {$textPending} {
         puts $sock "outFile $filename"  
         puts $sock "speakMe $text"
         }
     }
     
}

#-------------------------------------------------------------------------------
# ProcName : main
# Usage    : 
# Accepts  :
# Returns  :
# Called By:
#-------------------------------------------------------------------------------
 

  
 set verboseText 0
 set x 0
 set port 5491
 set attempt 0
 
 

# Process all arguments first to detect elements that affect behaviour from
# startup

   if {!$argc} {helpMe ; exit }
    
     foreach element $argv {
         if { $element == "-v" || $element == "--verbose" } {
             set verboseText 1
             bugMe "Client: verbose output"
         }
         if { $element == "-h" || $element == "--help" } { 
             helpMe
             exit
         }
         if { $element == "--port"} {
             
             set port [lindex $argv [expr $x + 1] ]
             
             if { $port  == "?"} { 
                 puts stderr "Error: You can not query the server port number\
                  from the client."
             }    
         } 
     incr x
     }

     if {$port == 0 || $port == "?"} {
         set port 5491
         bugMe "Looking for server on localhost port 5491 by default"
     }
     bugMe "Starting up..."
    
    if { [catch {set sock [socket localhost $port] } err] } {
        bugMe "Server unreachable attempting to start..."
        set sock [startUpSever $port]
    }
    
    fconfigure $sock -buffering line -blocking 0 -encoding utf-8
    fileevent $sock readable [list sapiRead $sock]
    
    bugMe "Client: Connected on $sock"
    
    while { $attempt < 6 } { 
        set x 0
            lappend readyCheckerID [after [expr {10000 * $attempt}] { 
                incr x
                puts $sock "readyServer"
                bugMe "Server Ready Test - Attempt No.$x"
                if { $x == 6} {
                    puts stderr "Server did not respond in reasonable time"
                    exit
                }
            }]
    incr attempt
    }    
     
vwait forever
 