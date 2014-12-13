#!/usr/bin/env perl


use Modern::Perl;
use Statistics::R;
use Browser::Open qw( open_browser);

die "$0 <full path to Rmd file without extension> " unless $#ARGV == 0;
my $R = Statistics::R->new() ;
my $path = shift;
my $browser = "/Applications/Safari.app/Contents/MacOS/Safari";
my @path = split '/', $path;


my $file = $path[-1];
pop @path;
my $wd = join '/', @path;
chdir $wd;

my $cmds = <<"EOF";
library(knitr);
knit2html("$file.rmd")
EOF
$R->run($cmds);
$R->stop();

my $ok = open_browser("$path.html", 1)
