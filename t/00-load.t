#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Signal::More' ) || print "Bail out!
";
}

diag( "Testing Signal::More $Signal::More::VERSION, Perl $], $^X" );
