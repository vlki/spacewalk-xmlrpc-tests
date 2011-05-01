#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# BeakerLib plugin containing functions for easier testing of XML-RPC
# interface of RHN Satellite/Spacewalk server.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

: <<=cut
=pod

=head1 NAME

beakerlib-satellite-xmlrpc.sh - RHN Satellite/Spacewalk XML-RPC tests

=head1 DESCRIPTION

This file contains functions for easier testing of XML-RPC interface of
RHN Satellite/Spacewalk server.

=head1 FUNCTIONS

=cut

# These can be overriden
Tomcat6LogFile=${TOMCAT6_LOG_FILE:-"/var/log/tomcat6/catalina.out"}
HttpdErrorLogFile=${HTTPD_ERROR_LOG_FILE:-"/var/log/httpd/error_log"}

# Default path is the same dir as test
SATELLITE_XMLRPC_SCRIPTS=${SATELLITE_XMLRPC_SCRIPTS:-"."}

# Default Spacewalk version is 1.2
SPACEWALK_VERSION=${SPACEWALK_VERSION:-"1.2"}

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
    
    if [ -e "$basePath/$SPACEWALK_VERSION/$scriptName" ]; then
        scriptExpanded="$basePath/$SPACEWALK_VERSION/$2"
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
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteSaveTomcat6Log

Backups the tomcat6 catalina.out log file into temporary file and sets the
variable $Tomcat6LogSaved to the name of that temporary file. Therefore
the caller is then responsible of removing it.

Returns 0.

=cut

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
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteSaveHttpdErrorLog

Backups the httpd error_log log file into temporary file and sets the
variable $HttpdErrorLogSaved to the name of that temporary file. Therefore
the caller is then responsible of removing it.

Returns 0.

=cut

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
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteAssertTomcat6LogNotDiffer

Assertion checking that the previously saved tomcat6 catalina.out log file 
does not differ from the current one. The previously saved log file name is
expected to be in $Tomcat6LogSaved variable.

Returns 0 and asserts PASS when log files does not differ.

=cut

rlSatelliteAssertTomcat6LogNotDiffer(){
    __INTERNAL_AssertLogNotDiffer "$Tomcat6LogSaved" "$Tomcat6LogFile" \
        "There should not be any addition to tomcat6 log"

    return $?
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteAssertHttpdErrorLogNotDiffer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteAssertHttpdErrorLogNotDiffer

Assertion checking that the previously saved httpd error_log log file 
does not differ from the current one. The previously saved log file name is
expected to be in $HttpdErrorLogSaved variable.

Returns 0 and asserts PASS when log files does not differ.

=cut

rlSatelliteAssertHttpdErrorLogNotDiffer(){
    __INTERNAL_AssertLogNotDiffer "$HttpdErrorLogSaved" "$HttpdErrorLogFile" \
        "There should not be any addition to httpd error log"

    return $?
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSpacewalkVersionIs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlSpacewalkVersionIs

Checks whether the given Spacewalk version is the same as the one of XML-RPC
interface.

    rlSpacewalkVersionIs version

=over

=item version

The version of the Spacewalk we want to compare with configured one, e.g. "1.2"

=back

Returns 0 if the version is same, 1 if not and 2 in case of error.

=cut

rlSpacewalkVersionIs(){
    if [ "$1" == "" ]; then
        __INTERNAL_LogAndJournalFail "rlSpacewalkVersionIs needs one parameter -- the version"
        return 2
    fi

    if [ $SPACEWALK_VERSION == "$1" ]; then
        return 0
    else
        return 1
    fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlLoadConfigProperty
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlLoadConfigProperty

Loads the property from config file with format used by Python ConfigParser.

    rlLoadConfigProperty config-file property-name

The value of property is saved into $rlLoadConfigProperty_VALUE variable.

=over

=item config-file

The path to the config file.

=item property-name

The name of the property we want to load.

=back

Returns 1 in case of problem, 0 otherwise.

=cut

rlLoadConfigProperty(){
    if [ ! -e "$1" ]; then
        __INTERNAL_LogAndJournalFail "rlLoadConfigProperty cannot find config file \"$1\""
        return 1
    fi

    rlLoadConfigProperty_VALUE=$( grep "$2=" "$1" | sed "s/^[^=]\+=\(.*\)$/\1/" | head -n1 )

    if [ -z "$rlLoadConfigProperty_VALUE" ]; then
        echo "rlLoadConfigProperty the value of property \"$2\" is missing or is empty"
        return 1
    fi

    return 0
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

