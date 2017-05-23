#!/bin/bash
#
# In case it should be verbose
VERBOSE=${VERBOSE:-true}

# Write into log file?
WRITELOG=${WRITELOG:-true}

# Work path
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

# Get Program-Name, shortened Version.
PROGNAME="`basename $0 .sh`"

# Execution PID.
PROG_PID=$$

# Version string
VER="1.1-b8"

# Directory we work in.
BASEDIR=`pwd`

# Build Date in reverse - Prefix to builds
DATE=`date +"%Y%m%d"`

# Date + Time for logs
LDATE=`date +"%F @ %T"`

# Lockfile to use.
# We don't want this script to run twice.
LockFile="${BASEDIR}/${PROGNAME}..LOCK"

# We need to provid the action to perform.
ACTION=$1

###############################################################################
# Nothing to configure below this point.
###############################################################################
# Directories to check for existance of previous installation
# Requisit package
mtpRequisitePackage='tim-mtp-requisites'
#
# TIM Packet package
mtpTimPackage='tim-mtp'

# Machine Setting package
mtpMachineSetting='machine/machine-settings'

# Better leave this one as is.
# Define the installation directory
install_dir="/usr/local/wily"


LogFile="${PROGNAME}".log

# Zero out Logfile.
cat /dev/null >> $LogFile

###############################################################################
# Log function - very small
log() {

    # Compute Date for the Logs.
    DATE=`date +"%F %T"`

    HEAD="${DATE}"

    # Be verbose
    ! $VERBOSE || echo "${HEAD} $*"

    if [ "$WRITELOG" != "false" ]
    then
        # Write it to the Log-File
	echo "${HEAD} $*" >> $LogFile
    fi
} # log function.
#
##############################################################################
space () {
    MSG="Add space to $LogFile"
    echo ""
    ! $WRITELOG || echo "" >> $LogFile
    errlvl=$?
    errors
}
##############################################################################
title () {
    # Set to
    line=""
    lg=`echo $* | wc -c`
    let length=($lg + 4)
    while [ $length -lt 80 ]; 
    do
        line="${line}="
        let length=($length + 1)
    done

    space
    space
    echo "==============================================================================="
    ! $WRITELOG || echo "===============================================================================" >> $LogFile
    errlvl=$?
    errors

    MSG="Add title: $* to $LogFile"
    echo "== $* $line"
    ! $WRITELOG || echo "== $* $line" >> $LogFile
    echo "==============================================================================="
    ! $WRITELOG || echo "===============================================================================" >> $LogFile
}
##############################################################################
separator () {
    MSG="Add separator to $LogFile"
    echo "================================================================================"
    ! $WRITELOG || echo "===============================================================================" >> $LogFile
    errlvl=$?
    errors

}
##############################################################################
entry () {

    # Set to
    line=""
    lg=`echo $* | wc -c`
    let length=($lg + 8)
    while [ $length -lt 80 ]; 
    do
        line="${line}="
        let length=($length + 1)
    done

    # Add a space
    space
    MSG="Add entry: $* to $LogFile"
    echo "=== $* !  $line"
    ! $WRITELOG || echo "=== $* !  $line" >> $LogFile
    errlvl=$?
    errors
}

#
##############################################################################
#
errors() {
    #DOC: The errors Function is called to control the exit status.
    #
    : ${errlvl:=9}
    : ${MSG:="No Error message - Probably user interruption"}
    if [ $errlvl -gt 0 ] ;
    then
	if [ $errlvl = 15 ] ;
	then
            $VERBOSE && echo -e "WARNING: $MSG"
	    $VERBOSE && echo "WARNING: An error occured, please check the log"
            echo "WARNING: $MSG" >> $LogFile
	else
            # Usage
            echo -e "\a"
            echo "FATAL:  An error occured in \"${PROGNAME}(${FUNCTION})\". Bailing out..."
            echo -e "ERRMSG: $MSG"
            echo
            echo "FATAL: $MSG" >> $LogFile
            Unlock $LockFile
            exit $errlvl
	fi
    fi
} # errors Function
#
##############################################################################
#
# Lockfile Generation
Lock() {
    # Lockfile to create
    tolock="$1"
    Action="$2"
    #
    # Lock file if lockfile does not exist.
    if [ -s $tolock ]
    then
	# If we have provided a second Var, set Exit status using  it.
	if [ ! -n "$Action" ]
	then
            # Oops, we  found a lockfile. Loop while checking if still exists.
            while [ -s $tolock ]
            do
		sleep 5 ;
            done
            MSG="Creating lockfile $tolock failed after 5 secs"
            # write PID into Lock-File.
            echo $$ > $tolock
            errlvl=$?
            errors
	else
            Pid="`cat $tolock`"
            Exists="`ps auxw | grep \" $Pid \" | grep -c $PROGNAME`"
            if [ $Exists = 1 ]
            then
		MSG="\"$PROGNAME\" already running. Exiting..."
		errlvl=$Action
		errors
            else
		MSG="Found stale lockfile... Removing it..."
		rm -f $tolock
		errlvl=$?
		errors
		MSG="Creating lockfile $tolock failed"
		echo $$ > $tolock
		errlvl=$?
		errors
            fi
	fi
    else
	# Lock it
	MSG="Creating lockfile $tolock failed"
	echo $$ > $tolock
	errlvl=$?
	errors
    fi
} # Lock
#
##############################################################################
#
Unlock(){
    # Name of Lockfile to unlock
    unlock="$1"
    # Unlock the file.
    if [ -s $unlock ]
    then
	PID=$$
	if [ "`cat $unlock`" != "$PID" ]
	then
            # Lock it
            echo -e "WARNING: Wrong lock-file PID. Probably a race-condition happened...\n"
	else
            # Removing Lockfile
            rm -f $unlock
	fi
    fi
    #
} # Unlock

#
##############################################################################


# Lockfile
LockFile="${BASEDIR}/${PROGNAME}..LOCK"

# Prevent double execution
Lock $LockFile 1

# Usage information.
usage() {
    echo
    echo " Usage: ./$PROGNAME.sh [ACTION]"
    echo
    echo " ACTION:"
    echo "     install  - installs the TIM software on a vMTP"
    echo "     remove   - removes the installed TIM from the vMTP"
    echo "     list     - lists installed TIM components"
    echo
    echo "     For the installation, the script needs the files:"
    echo "     - tim-mtp-requisites-Linux-el6-x64-*.image"
    echo "     - tim-mtp-Linux-el6-x64-*.image"
    echo
    echo "     downloaded from the CA Support/Download section and"
    echo "     placed in the same folder as the ${PROGNAME}.sh"
    echo
    echo " Restrictions:"
    echo "     It will not install the machine-settings nor the system-settings image!"
    echo "     It will only install on vMTP 10.6 or 11.x!"
}

##############################################################################
# Check if we have the require access level (We need to be root)

if [ $EUID != 0 ]
then
    echo
    echo "*** FATAL - root access is required to execute this script"
    echo "***         If root does not exist, \"sudo\" can be used." 
    usage
    echo
    exit 1
fi

# Log program version.
title "$LDATE `whoami`@`hostname -s` - ${PROGNAME}.sh version $VER"

#
##############################################################################
# Check if we have the required information
if [ "$ACTION" = "install" ] || [ "$ACTION" = "remove" ]  || [ "$ACTION" = "list" ]
then
    entry "Action requested: $ACTION"
else
    MSG="*** Error - No action provided!" 
    usage
    errlvl=1
    errors
fi


# Checking vMTP Version
if [ -f /opt/NetQoS/version.txt ]
then 
    vMTPV=`cat /opt/NetQoS/version.txt`
    title "vMTP version $vMTPV found"
    InstallTIM=no
    [[ "$CURVERSION" != 11.* ]] && InstallTIM=yes
    [[ "$CURVERSION" != 10.6* ]] && InstallTIM=yes
    
    if [ "$InstallTIM" = "no" ]
    then
	MSG="$PROGNAME only supports vMTP CLI installations on vMTP 10.6+. Aborting"
	errlvl=1
	errors
    fi
     
else
    MSG="No vMTP installation found. Aborting!"
    errlvl=1
    errors
fi


# In case we install, we need to make sure the installation directory
# exists. Will help on other operations too.
if [ ! -d $install_dir ]
then
    # Make sure the installation directory exists.
    MSG="Creating installation directory $install_dir failed"
    mkdir -p "$install_dir"
    errlvl=$?
    errors
    log "*** Creating installation directory: $install_dir"
else
    log "Existing installation directory: $install_dir"
fi

#
#### Actual script starts here #####
if [ "$ACTION" = "install" ]
then

    # We are working on 3 files. Hence, check these in order.
    #for file in machine-settings-mtp tim-mtp-requisites-Linux tim-mtp-Linux
    # We removed the "machine-settings-mtp", as it adds configuration capability
    # for time zone and systme restart etc.
    for file in tim-mtp-requisites-Linux tim-mtp-Linux
    do
	package=`ls ${file}-*.image 2>&1`
	title "Working on $package"
	
	case $file in
	    tim-mtp-system)
		entry "Checking if $file is already installed"
		# We need to check on the Link and the RPM here.
		if [ ! -h "/etc/wily/system" ]
		then
		    if [ -d /usr/local/wily/system ]
		    then
			log "Linking TIM system to MTP"
			MSG="linking /etc/wily/system"
			ln -s /usr/local/wily/system /etc/wily/system
			errlvl=$?
			errors
		    else
			log "vMTP installation missed installonce scripts. Aborting"
			MSG="linking /etc/wily/system"
			ln -s /usr/local/wily/system /etc/wily/system
			errlvl=$?
			errors
		    fi
		fi
		;;

	    machine-settings-mtp)
		entry "Checking if $file is already installed"
		log "checking for \"$install_dir/$mtpMachineSetting\""
		if [ -h "/etc/wily/machine/machine-settings" ]
		then
		    log "Uninstalling $mtpMachineSetting"
		    log "Executing \"$install_dir/$mtpMachineSetting/install/uninstall\""
		    MSG="Uninstalling $mtpMachineSetting failed"
		    $install_dir/$mtpMachineSetting/install/uninstall >> $LogFile 2>&1 
		    errlvl=$?
		    errors
		fi
		entry "Unpacking $file"
		MSG="Unpacking $package failed"
		tar xvf $package -C $install_dir >> $LogFile 2>&1 
		errlvl=$?
		errors
		echo ">> Running installer for $file"
		MSG="Running installer for $file"
		$install_dir/$mtpMachineSetting/install/install >> $LogFile 2>&1 
		errlvl=$?
		errors
		;;
	    tim-mtp-requisites-Linux)
		if [ ! -f "$package" ]
		then
		    usage
		    MSG="No installation image found. Aborting"
		    errlvl=1
		    errors
		fi
		entry "Checking if $file is already installed"
		log "checking for \"$install_dir/$mtpRequisitePackage\""
		if [ -h "/etc/wily/tim-mtp-requisites" ]
		then
		    log "Uninstalling $mtpRequisitePackage"
		    log "Executing \"$install_dir/$mtpRequisitePackage/install/uninstall\""
		    MSG="Uninstalling $mtpRequisitePackage"
		    $install_dir/$mtpRequisitePackage/install/uninstall >> $LogFile 2>&1 
		    errlvl=$?
		    errors
		fi
		entry "Unpacking $file"
		MSG="Unpacking $package failed"
		tar xvf $package -C $install_dir >> $LogFile 2>&1 
		errlvl=$?
		errors
		# This is probably to inhibit the TIM UI installation on
		# the MTP.
		entry "Removing existing image files from install dir"
		MSG="Removing image files failed"
		rm -fv $install_dir/$mtpRequisitePackage/files/*.image >> $LogFile 2>&1 
		errlvl=$?
		errors
		# Actual installer
		log "Running installer for $file"
		MSG="Running installer for $file"
		$install_dir/$mtpRequisitePackage/install/install >> $LogFile 2>&1 
		errlvl=0 # We have to catch the error condition from the
		# installer script here :(
		errors
		;;
	    tim-mtp-Linux)
		if [ ! -f "$package" ]
		then
		    usage
		    MSG="No installation image found. Aborting"
		    errlvl=1
		    errors
		fi
		entry "Checking if $file is already installed"
		# We need to check on the Link and the RPM here.
		if [ -h "/etc/wily/tim-mtp" ] || [ `rpm --quiet -q tim` ]
		then
		    log "Uninstalling $mtpTimPackage"
		    log "Executing \"$install_dir/$mtpTimPackage/install/uninstall\""
		    MSG="Uninstalling $mtpTimPackage"
		    $install_dir/$mtpTimPackage/install/uninstall >> $LogFile 2>&1
		    errlvl=$?
		    errors
		fi
		entry "Unpacking $file"
		MSG="Unpacking $package failed"
		tar xvf $package -C $install_dir >>$LogFile 2>&1
		errlvl=$?
		errors
		cat $install_dir/$mtpTimPackage/LICENSE.txt 
		errlvl=$?
		errors
		echo  "*** PLEASE READ THE LICENSE FILE and accept it." 
		echo  "*** Not accepting it will exit the installer without" 
		echo  "*** installing the TIM software." 
		echo
		echo -n "*** Type license [Accept|Reject]: "
		read license
		space
		separator
		if [ "$license" == "Accept" ] || [ "$license" == "Accepted" ]
		then
		    log "*** Type license [Accept|Reject]: $license"
		    # Date + Time for logs
		    LicDATE=`date +"%F @ %T"`
		    msg="Writing license acceptance to LICENSE.txt file failed"
		    echo "=====================================================" >> $install_dir/$mtpTimPackage/LICENSE.txt
		    errlvl=$?
		    errors
		    echo "Customer license acceptance: $license ($LicDATE)" >> $install_dir/$mtpTimPackage/LICENSE.txt
		    log "Entering \"Customer license acceptance: $license ($LicDATE)\" to LICENSE.txt"
		    space
		    title "License accepted, performing TIM installation - please wait..." 
		    #		    $install_dir/$mtpTimPackage/install/install >> $LogFile 2>&1
		    MSG="Tim installation failed"	    
		    $install_dir/$mtpTimPackage/install/install >> $LogFile 2>&1
		    errlvl=$?
		    errors
		    title "TIM Installation finished. Please configure the MTP/TIM Integration"
		    log "A full log has been placed into \"$LogFile\""
		    echo
		else
		    log "*** Type license [Accept|Reject]: $license"
		    title "License rejected..." 
		    MSG="License not accepted. Installation aborted"
		    errlvl=1
		    errors
		fi
		;;
	esac    
    done

elif [ "$ACTION" = "remove" ]
then

    for file in tim-mtp-Linux machine-settings-mtp tim-mtp-requisites-Linux tim-mtp-system
    do
	if [ "$file" != "tim-mtp-system" ]
	then
	    package=`ls ${file}-*.image`
	else
	    packet="system"
	fi
	title "Working on $title"
	entry "Checking if $file is installed"
	
	case $file in
	    machine-settings-mtp)
		log "checking for \"$install_dir/$mtpMachineSetting\""
		if [ -h "/etc/wily/machine/machine-settings" ]
		then
		    log "Uninstalling $mtpMachineSetting"
		    log "Executing \"$install_dir/$mtpMachineSetting/install/uninstall\""
		    MSG="Uninstalling $mtpMachineSetting failed"
		    $install_dir/$mtpMachineSetting/install/uninstall >> $LogFile 2>&1
		    errlvl=$?
		    errors
		    log "Removing remaining $mtpMachineSetting files"
		    MSG="Removing $install_dir/$mtpMachineSetting failed"
		    rm -rf $install_dir/$mtpMachineSetting
		    errlvl=$?
		    errors
		else
		    log "Skipped: $file no installed."
		fi
		
		;;
	    tim-mtp-requisites-Linux)
		log "checking for \"$install_dir/$mtpRequisitePackage\""
		if [ -h "/etc/wily/tim-mtp-requisites" ]
		then
		    log "Uninstalling $mtpRequisitePackage"
		    log "Executing \"$install_dir/$mtpRequisitePackage/install/uninstall\""
		    MSG="Uninstalling $mtpRequisitePackage"
		    $install_dir/$mtpRequisitePackage/install/uninstall >> $LogFile 2>&1
		    errlvl=$?
		    errors
		    log "Removing r$mtpRequisitePackage installation files"
		    MSG="Removing $install_dir/$mtpRequisitePackage failed"
		    rm -rf $install_dir/$mtpRequisitePackage
		    errlvl=$?
		    errors
		else
		    log "Skipped: $file no installed."
		fi
		;;
	    tim-mtp-Linux)
		# We need to check on the Link and the RPM here.
		if [ -h "/etc/wily/tim-mtp" ] || [ `rpm --quiet -q tim` ]
		then
		    log "Uninstalling $mtpTimPackage"
		    log "Executing \"$install_dir/$mtpTimPackage/install/uninstall\""
		    MSG="Uninstalling $mtpTimPackage"
		    $install_dir/$mtpTimPackage/install/uninstall >> $LogFile 2>&1
		    errlvl=$?
		    errors
		    log "Removing $mtpTimPackage installation files"
		    MSG="Removing $install_dir/$mtpTimPackage failed"
		    rm -rf $install_dir/$mtpTimPackage
		    errlvl=$?
		    errors
		else
		    log "Skipped: $file no installed."
		fi
		;;
	    tim-mtp-system)
		# We need to check on the Link and the RPM here.
		if [ -h "/etc/wily/system" ]
		then
		    log "Uninstalling tim-mtp-system"
		    log "Removing system link"
		    MSG="Removing /etc/wily/system link"
		    rm -f /etc/wily/system
		    errlvl=$?
		    errors
		    MSG="Removing /etc/wily/cem directory failed"
		    rmdir /etc/wily/cem
		    errlvl=$?
		    errors
		    # leaving files in iunstalldir. Re-installing
		    # these would require vMTP re-installation.
		else
		    log "Skipped: $file no installed."
		fi
		;;
	esac
    done
    # last spacer
    echo
    
elif [ "$ACTION" = "list" ]
then

    echo
    echo "Seeking for APM component:"
    
    # tim-mtp-system
    echo -n " > for tim-mtp-system: "
    if [ -h "/etc/wily/system" ]
    then
	system="/var/www/cgi-bin/wily/system/description"
	if [ -f $system ]
	then
	    echo "`tail -1 $system` (`ls -l --time-style=long-iso $system | cut -d " " -f 6,7`)"
	else
	    echo "Not found"
	fi
    else
	    echo "Not found"
    fi

    # machine-settings-mtp
    echo -n " > for machine-settings-mtp: "
    if [ -h "/etc/wily/machine/machine-settings" ]
    then
	masettings="/var/www/cgi-bin/wily/packages/machine/machine-settings/description"
	if [ -f $masettings ]
	then
	    echo "`tail -1 $masettings` (`ls -l --time-style=long-iso $masettings | cut -d " " -f 6,7`)"
	else
	    echo "Not found"
	fi
    else
	echo "Not found"
    fi

    # tim-mtp-requisites-Linux
    echo -n " > for tim-mtp-requisites-linux: "
    if [ -h "/etc/wily/tim-mtp-requisites" ]
    then
	echo "Installed (`ls -l --time-style=long-iso /etc/wily/tim-mtp-requisites | cut -d " " -f 6,7`)"
    else
	echo "Not found"
    fi
   
    echo -n " > for tim-mtp-linux: "
    # tim-mtp-Linux
    if [ -n "`rpm -q tim`" ]
    then
	description="`rpm -ql tim | grep description$`"
	if [ -n "$description" ]
	then
	    echo "`tail -1 $description` (`ls -l --time-style=long-iso $description | cut -d " " -f 6,7`)"
	else
	    echo "Not found"
	fi
    else
	echo "Not found"
    fi
    echo
    
else
    # Should not happen, but catch anyway
    MSG="*** Error - no argument provided" 
    usage
    errlvl=1
    errors

fi


# Remove Lock file
Unlock $LockFile
