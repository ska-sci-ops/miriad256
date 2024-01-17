#!/usr/local/bin/perl
#
# $Source: /nfs/atapplic/miriad/scripts/web/RCS/mirman.pl,v $
# $Id: mirman.pl,v 1.14 2019/01/10 03:11:16 mci156 Exp $
#
# Depends on 'rman' (PolyglotMan - formerly RosettaMan)
#
# Set up the environment.

use strict;
use CGI qw/:standard :form/;
use URI;

$CGI::POST_MAX        = 1024 * 10; #max 10kb post size
$CGI::DISABLE_UPLOADS = 1;         #no uploads

my ($site,$TOP,$miriad_uri,$miriad_dir);

$ENV{"MANPATH"} = "/nfs/atapplic/miriad/man:/usr/local/man:/usr/local/site/man:/usr/share/man:/usr/man:/usr/local/karma/man";

$site = 'www.atnf.csiro.au';
$TOP="/var/www/vhosts/$site";
$miriad_uri = "/computing/software/miriad";
$miriad_dir = "$TOP/htdocs/$miriad_uri";

die("No miriad dir $miriad_dir\n") if ( ! -d $miriad_dir );

my ($q, %inputs, $topic, $dest, $line, $page, $u, $scheme);

$q = new CGI;


  # Determine the request's scheme so we can redirect using the same.
  $u = url(-base => 1);
  $scheme = URI->new( $u )->scheme;
  $scheme = 'http' if ($scheme =~ /^$/);

  print <<"EOF";
Content-type: text/html

<HTML><HEAD>
<TITLE>Web-Based Miriad Topic/UNIX Man Command</TITLE>
</HEAD>
<BODY BGCOLOR=white>
<CENTER><H1>Web-Based Miriad Topic/UNIX Man Command</H1></CENTER>
EOF

print "u = '$u'<br>\n";
print "scheme = '$scheme'<br>\n";

print <<"EOF";
</BODY></HTML>
EOF
exit;

#------------------------------------------------------------------------
sub deamp1{
  my ($a,$b,$c);
  ($a) = @_;
  if($a =~ m{^(.+)(&\w+)$}){
    $a = $1;
    $b = $a;
    $c = $2;
  }else{
    $b = $a;
    $c = "";
  }
  $a =~ s{&amp;}{&}g;
  return "<A HREF=\"$a\">$b</A>$c";
}
