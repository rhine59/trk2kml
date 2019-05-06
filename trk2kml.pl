#!/usr/bin/perl
use File::Basename;
use Cwd qw(cwd);
my $directory = cwd;

# for all the .trk | .TRK files in the current directory
opendir (DIR, $directory) or die $!;
while (my $filename = readdir(DIR)) {
	($name,$dir,$ext) = fileparse($filename,'\..*');
	if ($ext =~ m/(.trk|.TRK)/) {
		my $rc = process_track_file($name,$ext);
	}
}
closedir(DIR);
exit 0;

# Process the PilotAware track file
sub process_track_file {
	my ($trackfile, $extension) = @_;
	print "*INFO* Processing PilotAware track file $trackfile$extension\n";
	my $trkfile = $trackfile . $extension;
	my $kmlfile = $trackfile . ".kml";

	open(TRACK, $trkfile) or die("*ERROR* Unable to open PilotAware track file $trkfile: $! \n");
	open(KML, '>', $kmlfile) or die("*ERROR* Unable to open Google Maps kml file $kmlfile: $! \n");

	print KML "\<?xml version=\"1.0\" encoding=\"utf-8\"?\>" . "\n";
	print KML "\<kml xmlns=\"http://www.opengis.net/kml/2.2\"\>" . "\n";
	print KML "\<Document\>" . "\n";
	print KML "    \<name\>PilotAware $trkfile\</name\>" . "\n";
	print KML "    \<description\>KML created by trk2kml.pl from the $trkfile Pilot Aware .trk file. See https://github.com/rhine59/trk2kml" . "\n";
	print KML "    \</description\>" . "\n";
	print KML "    \<Style id=\"yellowLineGreenPoly\"\>" . "\n";
	print KML "      \<LineStyle\>" . "\n";
	print KML "        \<color\>7f00ffff\</color\>" . "\n";
	print KML "        \<width\>4\</width\>" . "\n";
	print KML "      \</LineStyle\>" . "\n";
	print KML "      \<PolyStyle\>" . "\n";
	print KML "        \<color\>7f00ff00\</color\>" . "\n";
	print KML "      \</PolyStyle\>" . "\n";
	print KML "    \</Style\>" . "\n";
	print KML "    \<Placemark\>" . "\n";
	print KML "      \<name\>Absolute Extruded\</name\>" . "\n";
	print KML "      \<description\>Transparent green wall with yellow outlines\</description\>" . "\n";
	print KML "      \<styleUrl\>#yellowLineGreenPoly\</styleUrl\>" . "\n";
	print KML "      \<LineString\>" . "\n";
	print KML "        \<extrude\>1\</extrude\>" . "\n";
	print KML "        \<tessellate\>1\</tessellate\>" . "\n";
	print KML "        \<altitudeMode\>absolute\</altitudeMode\>" . "\n";
	print KML "        \<coordinates\>" . "\n";

	while ($entry = <TRACK>)  {
        	($id,$utc,$lat,$ns,$long,$we,$qual,$sat,$dil,$alt,$aunit,$junk) = split ',', $entry;
		# Process only the GPGGA sentences
        	if ($id eq "\$GPGGA") {
                	$lat =~ tr/.//d;
                	$long =~ tr/.//d;
                	print KML "          " . "-" . substr($long,0,3) . "." . substr($long,3,7) . "," . substr($lat,0,2) . "." . substr($lat,2,5) . "," . $alt . "\n";
        	}
	}

	close(TRACK);

	print KML "        \</coordinates\>" . "\n";
	print KML "     \</LineString\>" . "\n";
	print KML "   \</Placemark\>" . "\n";
	print KML "\</Document\>" . "\n";
	print KML "\</kml\>" . "\n";

	close KML;
	return $?;
}

