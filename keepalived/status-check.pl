#!/usr/bin/perl

use strict;
use Sys::Syslog;
use DBI;

my $trace = 1;
my $name  = $0;
$name =~ s|.*/||go;

openlog $name, "ndelay,pid", "local0";

# Short timeout
alarm(2);
$SIG{ALARM} = \&handle_alarm;

# Assume any password found in root's config is root's pw
my $pw;
my $user = "root";
open( my $in, "/root/.my.cnf" );
while ( defined( my $line = <$in> ) ) {
    if ( $line =~ /password\s*=\s*(.*?)\s*$/o ) {
        $pw = $1;
    }
    if ( $line =~ /user\s*=\s*(.*?)\s*$/o ) {
        $user = $1;
    }
    last if ( $pw && $user );
}
close($in);

my $dsn = "DBI:mysql:database=mysql";
my $db = DBI->connect( $dsn, $user, $pw );

if ( !$db ) {
    syslog( "LOG_INFO", "db connection/status failed" );
    exit(1);
}

if ( -e "/local/mysql/cluster" ) {
    if ($trace) {
        syslog( "LOG_INFO", "checking cluster status" );
    }

    my $qry = "show status like 'wsrep_ready'";
    my $cid = $db->prepare($qry);
    $cid->execute();
    my ( $label, $cstat ) = $cid->fetchrow();
    $cid->finish();
    if ( uc($cstat) ne "ON" )    # ready for queries
    {
        syslog( "LOG_INFO", "db connection/status failed - wsrep_ready=$cstat" );
        exit(1);
    }

    $db->disconnect();
}

if ($trace) {
    syslog( "LOG_INFO", "db connection/status ok" );
}
exit(0);

sub handle_alarm {
    syslog( "LOG_INFO", "request timed out, exiting with failure" );
    exit(1);
}
