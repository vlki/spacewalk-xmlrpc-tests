#!/bin/bash

# beakerlib-satellite-xmlrpc.sh - BeakerLib extension for RHN Satellite XML-RPC tests
# Authors: Jan Vlcek <xvlcek03@>
#
# Description: Extends BeakerLib with rlSatellite* functions
#
# TODO: license?

: <<=cut
=pod

=head1 NAME

beakerlib-satellite-xmlrpc.sh - BeakerLib extension for RHN Satellite XML-RPC tests

=head1 DESCRIPTION

This file contains functions related directly to testing. These functions are
non-specialized asserts, as well as several other functions related to testing.  

This file contains functions for easier testing of XML-RPC interface of
RHN Satellite server.

=head1 FUNCTIONS

=cut

Tomcat6LogFile="/var/log/tomcat6/catalina.out"
HttpdErrorLogFile="/var/log/httpd/error_log"

# TODO: which path is default?
SATELLITE_XMLRPC_SCRIPTS=${SATELLITE_XMLRPC_SCRIPTS:-"/some/default/path"}

SATELLITE_VERSION=${SATELLITE_VERSION:-"1.2"}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Internal Stuff
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

__INTERNAL_LogAndJournalPass() {
    rljAddTest "$1" "PASS"
}

__INTERNAL_LogAndJournalFail() {
    rljAddTest "$1 $2" "FAIL"
}

__INTERNAL_SatelliteXmlRpcRun() {
    local scriptName=$( cut -d" " -f1 <<< $2 )
    local scriptExpanded=""
    local basePath="$SATELLITE_XMLRPC_SCRIPTS/$1"
    
    if [ -e "$basePath/$SATELLITE_VERSION/$scriptName" ]; then
        scriptExpanded="$basePath/$SATELLITE_VERSION/$2"
    else
        scriptExpanded="$basePath/$2"
    fi

    # resolve the absolute path
    scriptExpanded=$( readlink -f "$scriptExpanded" )

    rlRun -s -l -t "$scriptExpanded" 0
    return 0
}

__INTERNAL_AssertLogNotDiffer(){
    if [ ! -e "$1" ]; then
        __INTERNAL_LogAndJournalFail "__INTERNAL_AssertLogNotDiffer cannot assert because log has not been probably saved before"
        return 1
    fi 

    AdditionTmpFile=$( mktemp )

    # Get just the new lines and strip the ">  " prefix
    diff "$1" "$2" | grep "^> " | cut -c 3- > "$AdditionTmpFile"

    # if addition is not empty
    if [ -s "$AdditionTmpFile" ]; then
        __INTERNAL_LogAndJournalFail "$3"
        rlLog "`cat $AdditionTmpFile`"
        return 1
    fi
    
    rm -f $AdditionTmpFile

    __INTERNAL_LogAndJournalPass "$3"
    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteXmlRpcFrontendRun                                                                 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteXmlRpcFrontendRun

Run the given XML-RPC script from library (actual path is affected by version
of RHN Satellite) against Satellite frontend API.

    rlSatelliteXmlRpcFrontendRun script

Output of the script is accessible in file of name specified in $rlRun_LOG 
variable. Caller is responsible for removing the file.

=over

=item script

The script which should be run from library, e.g. "auth.login.py admin redhat".

=back

Returns 0 and asserts PASS if the return value of script is 0 (FAIL otherwise).

=cut

rlSatelliteXmlRpcFrontendRun(){
    __INTERNAL_SatelliteXmlRpcRun "frontend" $1

    return $?
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteXmlRpcBackendRun                                                                 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteXmlRpcBackendRun

Run the given XML-RPC script from library (actual path is affected by version
of RHN Satellite) against Satellite backend API.

    rlSatelliteXmlRpcBackendRun script

Output of the script is accessible in file of name specified in $rlRun_LOG 
variable. Caller is responsible for removing the file.

=over

=item script

The script which should be run from library, e.g. "registration.welcome_message.py".

=back

Returns 0 and asserts PASS if the return value of script is 0 (FAIL otherwise).

=cut

rlSatelliteXmlRpcBackendRun(){
    __INTERNAL_SatelliteXmlRpcRun "backend" $1

    return $?
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteSaveTomcat6Log
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteSaveTomcat6Log(){
    rlRun "Tomcat6LogSaved=\`mktemp\`" 0 \
          "Creating the temporary file for tomcat6 log file"
    rlRun "cat $Tomcat6LogFile > $Tomcat6LogSaved" 0 \
          "Storing the contents of $Tomcat6LogFile"
    export Tomcat6LogSaved

    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteSaveHttpdErrorLog
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteSaveHttpdErrorLog(){
    rlRun "HttpdErrorLogSaved=\`mktemp\`" 0 \
          "Creating the temporary file for httpd error log file"
    rlRun "cat $HttpdErrorLogFile > $HttpdErrorLogSaved" 0 \
          "Storing the contents of $HttpdErrorLogFile"
    export HttpdErrorLogSaved

    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteAssertTomcat6LogNotDiffer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteAssertTomcat6LogNotDiffer(){
    __INTERNAL_AssertLogNotDiffer "$Tomcat6LogSaved" "$Tomcat6LogFile" \
        "There should not be any addition to tomcat6 log"

    return $?
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteAssertHttpdErrorLogNotDiffer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteAssertHttpdErrorLogNotDiffer(){
    __INTERNAL_AssertLogNotDiffer "$HttpdErrorLogSaved" "$HttpdErrorLogFile" \
        "There should not be any addition to httpd error log"

    return $?
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AUTHORS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut
=pod

=head1 AUTHORS

=over

=item *

Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>

=back

=cut

