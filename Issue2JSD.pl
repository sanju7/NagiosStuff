#!/usr/bin/perl

# This script would create a Jira incident ticket for every nagios incident
# Author: Sanjay Anand
# Email:hi@sanjayanand.pro
# Version: 0.02
# Date: 22-12-2016

use strict;
use warnings;
use JIRA::Client;

use Getopt::Std;
use Getopt::Long qw(:config no_ignore_case bundling);

my $jirauser = 'admin';
my $jirapasswd   = 'admin';
my $jiraurl  = 'https://prod-aws-elb-jira-oreg.us.cloud-analytic.exideo.co';

use vars qw( $assignee $state $type $attempt $hostname $servicedesc );
GetOptions(
    'help|h'          	=>  \&print_usage,
    'assignee|a=s'      =>  \$assignee,
	'state|s=s'			=>  \$state,
	'type|t=s'			=>  \$type,
	'attempt|A=i'		=>  \$attempt,
	'hostname|H=s'		=>  \$hostname,
	'servicedesc|S=s'	=>  \$servicedesc,
);


if(!$assignee or !$state or !$type or !$attempt or !$hostname or !$servicedesc) {
	print "\tUsage: jira_eventhandler -a <assignee>\n";
	print "\tCreates a jira bug assigned to <assignee> with a summary eq to the nagios service alias\n";
	print "\tand a description eq to the nagios service output for the service the eventhandler is attached to.\n";
	exit 3; #unknown
}

if($type ne "HARD") {
	# not doing anything till its reaaaally a problem
	exit 0; #ok
}

my $jira = JIRA::Client->new($jiraurl, $jirauser, $jirapasswd);
my $baseurl = $jira->getServerInfo()->{baseUrl};

my $newissue = $jira->create_issue({
    project => 'UCLSL0',
    type    => 'Incident',
    assignee => $assignee,
	reporter => 'Nagios Monitoring',
    summary => "$hostname: $servicedesc is $state", 
    description => "$hostname: $servicedesc is $state ($type : $attempt)", 
});
print "OK: Successfully created $baseurl/browse/$newissue->{key}\n";
exit 0; #ok
