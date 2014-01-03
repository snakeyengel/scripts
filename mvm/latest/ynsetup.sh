#!/bin/bash

# ynsetup.sh
# Setup script for the yantranet platform's digital signage module
# on the linux platform

# TODO:
# If the license file login fails, STOP! lol
#+ That's always a good idea, yeah?

# Variables
               profileID=22
               configDir='/etc/'
                agentDir='/opt/yantranet/agent/'
                 homeDir='/home/yantrauser/'
                   rcDir='rc2.d/'
        simpleGatewayDir='/opt/SimpleGatewayService/'
               hostsFile='hosts'
            hostnameFile='hostname'
          installXMLFile='install.xml'
simpleGatewayServiceFile='serviceconfig.xml'
           autoStartFile='.config/autostart/AppMonitor.desktop'
       installSourceFile='YantraNetInstallers/install.xml'
           installBackup='install.xml.bak'
             ynsetupConf='ynsetup.conf'
       ynsetupConfBackup='ynsetup.conf.bak'
                  boldOn='\033[1m'
                 boldOff='\033[0m'

######### Functions ##########

askConfigFile() {
  if [[ -e "$configDir$ynsetupConf" ]]
  then
    echo "A config file was found for this program"
    echo "Here are the contents:"
    echo ""
    echo "-----------------------------------------"
    cat "$configDir$ynsetupConf"
    echo "-----------------------------------------"
    echo ""
    local confChoice="Would you like to use it?"
    while :
    do
      read -e -p "$confChoice [Y/n] > "
      case $REPLY in
        Y | y | "" )
          echo "Okay. We will use it!"
          . $configDir$ynsetupConf
          useConfig='true'
          sleep .75
          break
        ;;
        N | n )
          echo "Okay. We will start fresh!"
          useConfig='false'
          sleep .75
          break
        ;;
        * )
          continue
      esac
    done
  else
    useConfig='false'
  fi
} # end askConfigFile()

writeConfigFile() {
  if [[ -f "$configDir$ynsetupConf" ]]
  then
    rm $configDir$ynsetupConfBackup
    mv -v $configDir$ynsetupConf $configDir$ynsetupConfBackup
    echo "The config file has been backed up."
  fi
  local myVars=( username newname description address1 address2 city state postal country )
  for (( i=0 ; i<"${#myVars[@]}" ; i++ ))
  do
    local theOne
    eval theOne=\$${myVars[$i]}
#    echo $theOne
    echo "${myVars[$i]}=\"$theOne\"" | tee -a $configDir$ynsetupConf
  done
} # end writeConfigFile()

copySrcInstall() {
  if [[ -e "$homeDir$installSourceFile" ]]
  then
    echo "Found original $installXMLFile in $homeDir"". Copying now..."
    cp -v $homeDir$installSourceFile $agentDir$installXMLFile
    chown root.root $agentDir$installXMLFile
    chmod 644 $agentDir$installXMLFile
  else
    echo "Ummm, we're gonna need to find an $installXMLFile somewhere fast!"
    echo $agentDir$installXMLFile $homeDir$installSourceFile
    exit 99
  fi
} # end copySrcInstall()

stopMonitor() {
  killall -q AgentMonitorService
} # end stopMonitor()
  
stopAgent() {
  killall -q Agent
} # end stopAgent

stopAppMonitor() {
  killall -q AppMonitor
} # end stopAppMonitor()

stopWebApp() {
  killall -q WebApp
} # end stopWebApp

versionInfo() {
  echo ""
  echo "     Name: $0"
  echo "  Version: 1.0.5"
  echo "   Author: Eric Young (eyoung@everwell.com)"
  echo "  Written: Nov. 10, 2012"
  echo ""
} # end versionInfo()

# Test for su priv's
whoaminow() {
  if [ $(id -u) != "0" ] ; then
    echo "You must have superuser privileges to run this application"
    echo ""
	  exit 99
  fi
} # end whoaminow()

helpBlurb() {
  cat <<__EOF__
Usage is: sudo $0 OPTIONS
Setup a YantraNet Digital-Signage device for either deployment into the field,
or for imaging as a generic device by removing all licensing and stopping all
YantraNet related startup applications and services.

  -c, -C, --create   Prepares a device for field deployment
  -p, -P, --prep     Removes all specific information and services in
                       preparation for capturing an image of the device for
                       use in a Clonezilla or similar environment
      --help     Display this help and exit
      --version  output version information and exit
__EOF__
} # end helpBlurb()

help() {
  # help is passed one argument: a 1 or a 2
  # 1 means to print help and continue where you left off.
  # 2 means to print help and exit
  if [ -z $1 ] ; then
    helpBlurb
    exit 1
  else
    case $1 in
      1 )
        helpBlurb
        break
      ;;
      2 | * )
        helpBlurb
        exit 0
    esac
  fi
} # end help()  

lcase() { 
  echo $1 | tr '[:upper:]' '[:lower:]' 
}

ucase() { 
  echo $1 | tr '[:lower:]' '[:upper:]'
}

checkHostName() {
  newname=$(echo "$1" | sed "s/^\W*\(\w+\)\W*$/\1/i1")
} # end checkHostName()

setMode() {
  echo ""
} # end setMode()

intro() {
  clear
  cat <<__EOF__

YantraNet Digital-Signage module setup
======================================
You will need to provide the following to complete the setup:
   1) Your YantraNet account username
   2) Your YantraNet account password
   3) Your device information
     a) The desired name for this media player
        (it must be unique across your signage network)
     b) The complete physical mailing address of where this
        device will be installed
     c) A brief but meaningful description of this device
        e.g. "Breakroom player", "East Waiting Room", etc.

Please note: you will be able to review and change any entry
before any changes are made to the filesystem.

Characters inside these: [abc] are either existing values,
such as [current device name] or are choices to be made, such as [Y/n].

[Y/n] means that the choices are Yes (Y) or No (n) and that if you press
Enter without typing anything, your choice will be Y or Yes.
You may type upper or lowercase responses.

__EOF__

} # end intro()

confirmConfirm() {
  local choice
  local prompt="Are you sure?? [yes/n] >"
  echo -n $prompt
  read choice
  while :
  do
    case $choice in
      yes | YES | Yes )
        break
      ;;
      n | N )
        echo ""
        echo "Goodbye!"
        exit 0
      ;;
      * )
        echo -n $prompt
        read choice
    esac
  done
} # end confirmConfirm()

startConfirm() {
  local choice
  local prompt="Are you ready to proceed? [y/n] >"
  echo -n $prompt
  read choice
  while [ true ]
  do
    case $choice in
      y | Y )
        confirmConfirm
        clear
        break
      ;;
      n | N )
        echo ""
        echo "Goodbye!"
        exit 0
      ;;
      * ) 
        echo -n $prompt
        read choice
    esac
  done
} # end startConfirm()

unameAsk() {
  local prompt="Enter your YantraNet account username"
  if [[ ! -z "$username" ]]
  then
    read -e -i $username -p "$prompt [$username]> "
    case $REPLY in
      "" | $username )
        echo "  Your username will remain unchanged: $username"
        echo ""
        editParams
        break
      ;;
      * )
        username=$REPLY
        echo "  Your username will now be: $username"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read username
    while [ true ]
    do
      case $username in
        "" )
          echo -n "$prompt >"
          read username
          continue
        ;;
        * )
          echo "  Your username has now been changed to: $username"
          echo ""
          break
      esac
    done
  fi
} # end unameAsk()

passwordAsk() {
  echo ""
  local prompt="Enter your YantraNet account password"
  echo -n "$prompt >"
  pchoice=""
  read -s pchoice
  while :
  do
    case $pchoice in
      "" )
        echo ""
        echo -n "$prompt >"
        read -s
        continue
      ;;
      * )
        echo ""
        echo -n "Re-enter your password to confirm it > "
        passwordConfirm "$pchoice"
        if [[ "$pchoice" == "$pcChoice" ]]
        then
          password="$pchoice"
          echo ""
          echo "  Your password has now been set."
          echo ""
          break
        else
          echo ""
          echo "The two entries did NOT match"
          password=""
          passwordAsk
        fi
        break
    esac
  done
} # end passwordAsk()

passwordConfirm() {
  pcChoice=""
  read -s pcChoice
  case $pcChoice in
    "$pchoice" )
      return 0
    ;;
    * )
      password=""
  esac
} # end passwordConfirm()

hostnameAsk() {
  echo ""
  local destination

  if [[ ! -z "$1" ]] ; then
    destination=$1
  fi
  
  # Get the current hostname
  devname=`hostname`
  local prompt="What would you like to call this media player? [$devname] >"
  if [[ ! -z "$newname" ]]
  then
    read -e -i "$newname" -p "$prompt " newname
  else
    read -e -p "$prompt " newname
  fi

  if [[ ! -z "$newname" ]]
  then # If anything was entered at all
    newname=$(ucase $newname) # Make it all uppercase
    checkHostName "$newname"
  fi

  case $newname in
    "$devname" | "" ) ### No change was made or the same name was typed in
      newname=$(ucase $devname)
      echo "  Device will remain $devname"
      echo ""
      if [ ! -z $destination ] ; then
        editParams
        break
      fi
    ;;
    * )
      echo "  The device name will be changed to $newname"
      echo ""
      if [ ! -z $destination ] ; then
        editParams
        break
      fi
  esac
} # end hostNameAsk()

address1Ask() {
  local prompt1="Please enter the street address: eg. 123 Main St"
  local prompt2

  if [[ ! -z "$address1" ]]
  then
    prompt2=`cat <<__EOF__
Current street address is
  [$address1]
__EOF__`

    echo $prompt2
    read -e -i "$address1" -p "$prompt1> "
    case $REPLY in
      $address1 | "" )
        echo "The street address will remain the same"
        echo "  $address1"
        echo ""
        editParams
        break
      ;;
      * )
        echo "The new street address is:"
        address1=$REPLY
        echo "  $address1"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt1 >" 
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt1 >"
          read
          continue
        ;;
        * )
          echo "The new street address is:"
          address1=$REPLY
          echo "  $address1"
          echo ""
          break
      esac
    done
  fi        
} # end addressAsk1()

address2Ask() {
  local prompt1="Enter the suite, building, floor or room #:"
  local prompt2

  if [[ ! -z "$address2" ]]
  then
    prompt2=`cat <<__EOF__
Current secondary address is
  [$address2/!! (delete)]

__EOF__`

    echo $prompt1
    read -e -i "$address2" -p "$prompt2> "
    case $REPLY in
      $address2 | "" )
        echo "The secondary address will remain the same"
        echo "  $address2"
        echo ""
        editParams
        break
      ;;
      !! )
        address2=""
        echo "Address 2 has been reset to no value"
        editParams
        break
      ;;
      * )
        echo "The new secondary address is:"
        address2=$REPLY
        echo "  $address2"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt1 >" 
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo "  There is no secondary address at this location"
          echo ""
          break
        ;;
        * )
          echo "The new secondary address is:"
          address2=$REPLY
          echo "  $address2"
          echo ""
          break
      esac
    done
  fi        
} # end addressAsk2()

cityAsk() {
  local prompt="Enter the City"
  
  if [[ ! -z "$city" ]]
  then
    read -e -i "$city" -p "$prompt [$city]> "
    case $REPLY in
      $city | "" )
        echo "The city will remain the same"
        echo "  $city"
        echo ""
        editParams
        break
      ;;
      * )
        city=$REPLY
        echo "  The city is now $city"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt >"
          read
          continue
        ;;
        * )
          city=$REPLY
          echo "  The city will be set to $city"
          echo ""
          break
      esac
    done
  fi
} # end of cityAsk()

stateAsk() {
  local prompt="Enter the State name"
  
  if [[ ! -z "$state" ]]
  then
    read -e -i $state -p "$prompt [$state]> "
    case $REPLY in
      $state | "" )
        echo "The state will remain the same"
        echo "  $state"
        echo ""
        editParams
        break
      ;;
      * )
        state=$REPLY
        echo "  The state is now $state"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt >"
          read
          continue
        ;;
        * )
          state=$REPLY
          echo "  The state will be set to $state"
          echo ""
          break
      esac
    done
  fi
} # end of stateAsk()

postalAsk() {
  local prompt="Enter the Zip or postal code"
  
  if [[ ! -z "$postal" ]]
  then
    read -e -i $postal -p "$prompt [$postal]> "
    case $REPLY in
      $postal | "" )
        echo "The postal code will remain the same"
        echo "  $postal"
        editParams
        break
      ;;
      * )
        postal=$REPLY
        echo "  The postal code is now $postal"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt >"
          read
          continue
        ;;
        * )
          postal=$REPLY
          echo "  The postal code will be set to $postal"
          echo ""
          break
      esac
    done
  fi
} # end of postalAsk()

countryAsk() {
  local prompt="Enter the Country name"
  
  if [[ ! -z "$country" ]]
  then
    read -e -i $country -p "$prompt [$country]> "
    case $REPLY in
      $country | "" )
        echo "The country will remain the same"
        echo "  $country"
        echo ""
        editParams
        break
      ;;
      * )
        country=$REPLY
        echo "  The country is now $country"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt >"
          read
          continue
        ;;
        * )
          country=$REPLY
          echo "  The country will be set to $country"
          echo ""
          break
      esac
    done
  fi
} # end of countryAsk()

descriptionAsk() {
  local prompt="Enter the Description for the device"
  
  if [[ ! -z "$description" ]]
  then
    read -e -i "$description" -p "$prompt [$description]> "
    case $REPLY in
      $description | "" )
        echo "The description will remain the same"
        echo "  $description"
        echo ""
        editParams
        break
      ;;
      * )
        description=$REPLY
        echo "  The description is now $description"
        echo ""
        editParams
        break
    esac
  else
    echo -n "$prompt >"
    read
    while [ true ]
    do
      case $REPLY in
        "" )
          echo -n "$prompt >"
          read
          continue
        ;;
        * )
          description=$REPLY
          echo "  The description will be set to $description"
          echo ""
          break
      esac
    done
  fi
} # end of descriptionAsk()

recap() {
  if [[ ! -z "$1" ]] && [[ "$1"="c" ]]
  then
    clear
  fi
  
  if [[ -z "$password" ]]
  then
    local passDisplay="$boldOn""EMPTY! Please Provide!""$boldOff"
  else
    local passDisplay="$boldOn""hidden password""$boldOff"
  fi
  
  if [[ ! -z "$address2" ]]
  then
    recap=`cat <<__EOF__
$boldOn Parameter Review:
  User Information $boldOff
      $username/[$passDisplay]
  $boldOn Device Information $boldOff
      Name: $newname
      Description: $description
      Location:
        $address1
        $address2
        $city, $state $postal $country

__EOF__`
  else
    recap=`cat <<__EOF__
Parameter Review:
  User Information
      $username/[$passDisplay]
  Device Information
      Name: $newname
      Description: $description
      Location:
        $address1
        $city, $state $postal $country

__EOF__`
  fi
  echo -e "$recap"
} # end of recap()  

review() {
  local choice
  recap c
  echo ""
  echo "You will be prompted for your password if it is not set."
  echo -n "Are you satisfied with these parameters? [y/n] > "
  read choice
  
  while :
  do
    case $choice in
      y | Y )
        if [[ -z "$password" ]]
        then
          passwordAsk
          continue
        fi
        process_files "wget -q -O response.xml \
        --post-data=username=$username&password=$password&profile_id=$profileID&host_name=$newname&address1=$address1&address2=$address2&city=$city&state=$state&postal=$postal&country=$country&description=$description \                    
        http://api.yantranet.com/ynt/app/v0.2/system/license_manager/create"
        break
      ;;
      n | N )
        echo "I am unsatisfied and I have a curve!"
        editParams
        break
      ;;
      * )
        echo ""
        echo "You will be prompted for your password if it is not set."
        echo -n "Are you satisfied with these parameters? [y/n] >"
        read choice
        continue
    esac
  done
} # end review()

change_name() {
  # Accepts two possible arguments:
  #   1) $1 should be the desired hostname for the machine
  #   2) $2 is an optional parameter denoting that this function was called by
  #+     the script in -p or --prep mode and to not add the name of the device
  #+     to the SimpleGatewayServiceFile, but simply remove the name from it
  #+     entirely
  # The form is change_name $newname
  
  echo "Changing the name and related files now..."
  local nn=$1

  sed -i.bak "1 c $1" $configDir$hostnameFile
  if [[ "$?" = "0" ]]
  then
    echo "$configDir$hostnameFile has been updated"
  else
    echo "$configDir$hostnameFile has NOT been updated"
  fi

  sed -i.bak "/127.0.1.1/c 127.0.1.1 $1" $configDir$hostsFile
  if [[ "$?" = "0" ]]
  then
    echo "$configDir$hostsFile file has been updated"
  else
    echo "$configDir$hostsFile file has NOT been updated"
  fi

  if [[ ! -z "$2" ]]
  then
    sed -i.bak "/<Name>/c \\\t<Name></Name>" $simpleGatewayDir$simpleGatewayServiceFile
  else
    sed -i.bak "/<Name>/c \\\t<Name>$1</Name>" $simpleGatewayDir$simpleGatewayServiceFile
  fi
  
  if [[ "$?" = "0" ]]
  then
    echo "$simpleGatewayDir$simpleGatewayServiceFile file has been updated"
  else
    echo "$simpleGatewayDir$simpleGatewayServiceFile file has NOT been updated"
  fi

  echo ""
} # end change_name()

agentControl() {
  if [[ "$#" -lt 1 ]] 
  then
    echo "$0 was called without the required argument"
    echo "  The proper call is $0 [start/stop]"
    echo "Nothing has been done"
    return 1
   elif [[ "$1" = "start" ]]
    then
      if [[ -e $(eval echo $configDir$rcDir"K*yantranet_agentMonitor.sh") ]] && [[ ! -e $(eval echo $configDir$rcDir"S*yantranet_agentMonitor.sh") ]]
      then
        mv $(eval echo $configDir$rcDir"K99yantranet_agentMonitor.sh" $configDir$rcDir"S99yantranet_agentMonitor.sh")

        if [ "$?" = "0" ]; then
          echo "The Yantranet Agent Monitor service has been enabled"
        fi
      elif [[ -e $(eval echo $configDir$rcDir"S*yantranet_agentMonitor.sh") ]] && [[ ! -e $(eval echo $configDir$rcDir"K*yantranet_agentMonitor.sh") ]]
      then
        echo "The Yantranet Agent Monitor service has already been enabled"
        echo "We will skip that part."
        echo ""
      else
        echo "I could not find a link to the yantranet_agentMonitor beginning with S or K in $configDir$rcDir"
        echo "You should check that directory manually to see if there was a misspelling of the name"
        echo "or whether the link has been dissolved somehow, in which case you will need to"
        echo "recreate it appropriately. It is suggested that you contact your YantraNet"
        echo "representative before doing this."
      fi
  elif [[ "$1" = "stop" ]]
    then
      if [[ -e $(eval echo $configDir$rcDir"S*yantranet_agentMonitor.sh") ]] && [[ ! -e $(eval echo $configDir$rcDir"K*yantranet_agentMonitor.sh") ]]
      then
        mv $(eval echo $configDir$rcDir"S99yantranet_agentMonitor.sh" $configDir$rcDir"K99yantranet_agentMonitor.sh")

        if [ "$?" = "0" ]; then
          echo "The Yantranet Agent Monitor service has been disabled"
        fi
      elif [[ -e $(eval echo $configDir$rcDir"K*yantranet_agentMonitor.sh") ]] && [[ ! -e $(eval echo $configDir$rcDir"S*yantranet_agentMonitor.sh") ]]
      then
        echo "The Yantranet Agent Monitor service has already been disabled"
        echo "We will skip that part."
        echo ""
      else
        echo "I could not find a link to the yantranet_agentMonitor beginning with S or K in $configDir$rcDir"
        echo "You should check that directory manually to see if there was a misspelling of the name"
        echo "or whether the link has been dissolved somehow, in which case you will need to"
        echo "recreate it appropriately. It is suggested that you contact your YantraNet"
        echo "representative before doing this."
      fi
  else
    echo "I don't know what you want me to do. Please pass me either a 'start'"
    echo "or a 'stop', but not a '$1'! Nothing has been done"
  fi
} # end agentControl()

startupControl() {
  if [[ "$#" -lt 1 ]]
  then
    echo "$0 was called without the required argument"
    echo "  The proper call is $0 [start/stop]"
    echo "Nothing has been done"
    return 1
  elif [[ "$1" = "start" ]]
  then
    if [ -f "$homeDir$autoStartFile" ]; then
      sed -i.bak "s/\(X-MATE-Autostart-enabled=\).*/\1true/" $homeDir$autoStartFile
      sed -i.bak "s/\(Comment[en_US]=\).*/This starts the YantraNet WebApp upon system startup/" $homeDir$autoStartFile
      if [ "$?" = "0" ]; then
        echo ""
        echo "The digital signage module will start automatically on startup"
      else
        echo ""
        echo "There was a problem modifying the $homeDir$autoStartFile file"
        echo "You should manually enable the WebApp from the main menu of the desktop"
      fi
    else
      echo "Can't find $homeDir$autoStartFile for writing. Sorry."
      exit 1
    fi
  elif [[ "$1" = "stop" ]]
  then
    if [ -f "$homeDir$autoStartFile" ]; then
      sed -i.bak "s/\(X-MATE-Autostart-enabled=\).*/\1false/" $homeDir$autoStartFile
      sed -i.bak "s/\(Comment[en_US]=\).*/This starts the YantraNet WebApp upon system startup/" $homeDir$autoStartFile
      if [ "$?" = "0" ]; then
        echo ""
        echo "The digital signage module will NOT start automatically on startup"
      else
        echo ""
        echo "There was a problem modifying the $homeDir$autoStartFile file"
        echo "You should manually enable the WebApp from the main menu of the desktop"
      fi
    else
      echo "Can't find $homeDir$autoStartFile for writing. Sorry."
      exit 1
    fi
  else
    echo "You should pass this function either a 'start' or a 'stop' and not"
    echo "the '$1' that you did. Nothing has been done."
  fi
} # end startupControl()

process_files() {
  echo "Processing player request..."
  $1 #execute the wget command and get the response
  # First get the license key from the response.xml file and assign it to $license_key
  license_key=`grep -P -i -o -m 1 '(\w{0,8}-\w{4}-\w{4}-\w{4}-\w{0,12})' response.xml >&1`
  if [[ ! -z "$license_key" ]]
  then
    echo ""
    echo "Processing files..."
    echo ""
    echo "You have received the following license key:"
    echo "$license_key"
    echo ""
  else
    echo ""
    echo "There was an error retrieving the license key from the server"
    password=""
    echo "The password is being reset. You will need to re-enter the correct one"
    sleep 9
    review
  fi

###############################################################################
# Variables (for review only)
#               profileID=22
#               configDir='/etc/'
#                agentDir='/opt/yantranet/agent/'
#                 homeDir='/home/yantrauser/'
#                   rcDir='/rc2.d/
#        simpleGatewayDir='/opt/SimpleGatewayService/'
#               hostsFile='hosts'
#            hostnameFile='hostname'
#          installXMLFile='install.xml'
#simpleGatewayServiceFile='serviceconfig.xml'
#           autoStartFile='.config/autostart/AppMonitor.desktop'
#       installSourceFile='YantraNetInstallers/install.xml' # Needs chown/chmod'ing
#           installBackup='install.xml.bak'
#             ynsetupConf='ynsetup.conf'
###############################################################################

  echo "Updating the installation file"
  copySrcInstall # make sure there is an install.xml file in existence!
  if [[ -e "$agentDir$installXMLFile" ]] && [[ -f "$agentDir$installXMLFile" ]]
  then
    sed -i.bak "/<license_uuid>/c \\\t<license_uuid>$license_key</license_uuid>" $agentDir$installXMLFile >&1
    if [ "$?" = "0" ]; then
      echo ""
      echo "The license key has been updated"
      rm /home/yantrauser/bin/response.xml
      if [ "$?" = "0" ]; then
        echo "Installation files have been updated"
      fi
    else
      echo ""
      echo "There was an error processing the license key file!"
    fi
  else
    echo ""
    echo "There was no $installXMLFile file in the $agentDir directory"
    echo "All attempts to create it, re-create it, retrieve it from backup or"
    echo "from the initial installation sources has failed. This should"
    echo "DEFINITELY be investigated now!"
    exit 86
  fi
  
  echo ""
  echo "Enabling the Yantranet Agent Monitor"
  
  agentControl start
  startupControl start
  change_name $newname

  local lastPrompt=`cat <<__EOF__
You need to restart the player for all the changes to take effect
Would you like to restart now?
__EOF__`
  while :
  do
    echo -n "$lastPrompt [y/n] > "
    read
    case $REPLY in
      y | Y )
        confirmConfirm
        reboot
      ;;
      n | N )
        exit 0
      ;;
      * )
        continue
    esac
  done
} # end process_files()

editParams() {
  PS3="Which one? > "
  recap c
  local choices="Username Password Hostname Description Address1 Address2 City State Zip-code Country Review Exit Done"
  local choice
  select choice in $choices
  do
    case $choice in
      Username )
        unameAsk ;;
      Password )
        passwordAsk ;;
      Hostname )
        hostnameAsk ;;
      Description )
        descriptionAsk ;;
      Address1 )
        address1Ask ;;
      Address2 )
        address2Ask ;;
      City )
        cityAsk ;;
      State )
        stateAsk ;;
      Zip-code )
        postalAsk ;;
      Country )
        countryAsk ;;
      Review )
        editParams ;;
      Exit )
        select subchoice in "Save Config" "Exit without saving"
        do
          case $subchoice in
            "Save Config" )
              writeConfigFile
              exit 0
            ;;
            "Exit without saving" )
              exit 0
          esac
        done
      ;;
      Done )
        writeConfigFile
        review
        break
    esac
  done
} # end editParams()
###############################################################################
# End of functions for -c/-C/--create #########################################
###############################################################################


###############################################################################
# Functions for Image Preparation #############################################
###############################################################################

pIntro() {
  clear
  dte=$(date +%m-%d-%y)
  cat <<__EOF__

YantraNet Digital-Signage module image preparation
==================================================
This will prepare this player to be used in the creation of a master image.
All existing information that makes this device unique on the YantraNet platform
will be removed and the device will be renamed to "MSTR$dte"

__EOF__

} # end intro()

tidyUp() {
  if [[ -e "$agentDir$installBackup" ]]
  then
    rm -f "$agentDir$installBackup"
    if [[ "$?" = "0" ]]
    then
      echo ""
      echo "The $agentDir$installBackup file has been removed"
      echo ""
    fi
  fi
  
  if [[ -e "$configDir$ynsetupConfBackup"  ]]
  then
    rm -f "$configDir$ynsetupConfBackup"
    if [[ "$?" = "0" ]]
    then
      echo ""
      echo "The $configDir$ynsetupConfBackup file has been removed"
      echo ""
    fi
  fi 
  local prompt="Would you like to remove the config file, too?"
  while :
  do
    echo "$prompt [Y/n] > "
    read
    case $REPLY in
      y | Y | "" )
        echo "Okay, I'll take care of that for you"
        if [[ -e "$configDir$ynsetupConf" ]]
        then
          rm -f "$configDir$ynsetupConf"
          if [[ "$?" = "0" ]]
          then
            echo ""
            echo "The $configDir$ynsetupConf file has been removed"
            echo ""
          fi
        fi
        break
      ;;
      n | N )
        echo "Okay, I will leave it there for future generations to admire"
        break
      ;;
      * )
        continue
    esac
  done
} # end of tidyUp()

resetEverything() {
  if [[ -e "$agentDir$installBackup" ]]
  then
    rm -f "$agentDir$installBackup"
  fi
  copySrcInstall
  agentControl stop
  startupControl stop
  tidyUp
} # end resetEverything()


###############################################################################
# MAIN ########################################################################
###############################################################################
whoaminow

# Process the options
if [[ $# -eq 0 ]] ; then
  help
else
  mode=$1
  case $mode in
    -c | -C | --create )
      stopMonitor
      stopAgent
      stopAppMonitor
      stopWebApp
      intro
      startConfirm
      askConfigFile
      if [[ "$useConfig" = "true" ]]
      then
        review
        exit 0
      else
        unameAsk
        passwordAsk
        hostnameAsk
        descriptionAsk
        address1Ask
        address2Ask
        cityAsk
        stateAsk
        postalAsk
        countryAsk
        review
        exit 0
      fi
    ;;
    -p | -P | --prep )
      stopMonitor
      stopAgent
      stopAppMonitor
      stopWebApp
      pIntro
      startConfirm
      newname="MSTR$dte"
      change_name $newname -p
      resetEverything
      hostname -F "$configDir$hostnameFile"
      exit 0
    ;;
    --help )
      help 2
      exit 0
    ;;
    --version )
      versionInfo
      exit 0
    ;;
    * )
      help
  esac
fi

exit 0
