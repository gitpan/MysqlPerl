use ExtUtils::MakeMaker;
require 5.002;
$Verbose++ if $ENV{USER} eq "k";


WriteMakefile(
	NAME       => "Mysql",
	"DISTNAME" => "MysqlPerl",
	"dist"     => { SUFFIX   => ".gz", DIST_DEFAULT => 'all tardist',
			    COMPRESS => "gzip -9f" },
        VERSION_FROM => "lib/Mysql.pm",
	EXE_FILES => [qw(pmysql)],
	CONFIGURE  => \&initialize,
);

sub MY::postamble {
    return qq{
pure_all :: FAQ.html

FAQ.html : FAQ
	pod2html FAQ
};
}


sub initialize {
    my %X=();
    my @msqldir = qw(/usr/src/mysql/);
    my($msqldir,$gooddir);

    for $msqldir (@msqldir) {
	if (-f "$msqldir/include/mysql.h") {
	    $gooddir = $msqldir;
	    last;
	}
    }
    $gooddir ||= $msqldir[0];
    $gooddir=prompt("
Where is your mysql installed? Please name the directory that contains
the subdirs lib/ and include/.",$gooddir);
    
    my $headerdir="$gooddir/include";
    die "No mysql.h file found\n" unless -f "$headerdir/mysql.h";
    my $libdir="$gooddir/lib";
    
    @headerfiles = ("$headerdir/mysql.h");
    $X{LIBS}     = "-L$libdir -lmysql";
    $X{INC}      = "-I$headerdir";
    $X{H}        = \@headerfiles;
    \%X;
}


