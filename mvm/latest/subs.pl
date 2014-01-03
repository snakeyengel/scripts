sub ssCatcher {
  /^.*(ss |ss-|ss\d{1,6}|site|survey).*\.(pdf|tif|tiff)$/i;
  }

sub contractCatcher {
  /^.*(agreement|contract|[^survey]|[^ss|ss |ss-]).*\.(pdf|tif|tiff|jpg)$/i;
  }

sub Outer {
  ( my $fullname, my $dirpath ) = split ( ',', shift );
  my $bollocks = shift;
  my ( $id, $first, $third );
  $bollocks =~ /^(.*)(ss |site|survey)(.+?)\.(pdf|tif|tiff|jpg)$/i;
  
  if ( $1 ) {
    $first = $1;
  	
  	if ( $first =~ /.*?(\d{5,6}).+?/ ) {
      if ($debug > 0) {
        print "1st\n";
      }
      $p++;
      $id = $1;
    }

  } elsif ( $3 ) {
    $third = $3;
    if ( $debug > 0 ) {
      print "3rd\n";
    }
  	$d++;
  	$id = "$3";

	}	else {
	  if ( $debug > 0 ) {
	    print "Ugh\n";
	  }
	  $q++;
	  $id = "";
	  return 0;
  }

  if ( $id and $id ne "" ) {
    $x++;
    $record{$id . "," . $dirpath} = $bollocks;
  }

}

sub Fixer {
	my $name = shift;
	open FIX, "$name" or die "Cannot open $name: $!";
	my $ofile = $name . ".fixed";
	open FIXED, ">$ofile" or die "Cannot write to $ofile: $!";

	while ( <FIX> ) {
		my $hmmm = $_;
		$hmmm =~ s/\r\n|\n|\r/\n/g;
		print FIXED "$hmmm";
	}

	close FIX;
	close FIXED;
	return $ofile;
}

sub FileNames {
	my $type = shift;
	my $raw = shift;
	my $newdir = shift;
	my $docs = "docs/";
	my ( $filename, $directories, $suffix ) = fileparse( $raw, qr/\.[^.]*+/ );
	my $ss = "ss_";
	my $contract = "contract_";
	$raw =~ /.*?(\d{5,6}+)(.+?|.?)/;
	my $id = $1;
	$suffix = lc( $suffix );

	if ( $type eq 's' ) {
		my $newname = $newdir . $docs . $ss . $id . $suffix;
		return $newname;
	} elsif ( $type eq 'c' ) {
		my $newname = $newdir . $docs . $contract . $id . $suffix;
		return $newname;
	}
}

sub FilePathCatcher {
    my $path = shift;
    my ( $filename, $directory ) = fileparse( $path );
    &DirSaver( $directory );
    return $filename;    
}

sub FileSpecCatcher {
    my $path = shift;
    my( $volume, $directory, $filename ) = File::Spec->splitpath( $path );
    return $filename;
}

sub DirSaver {
    my $dir = shift;
    print $dir . "\n";
}

sub DirMaker {
    my $goodpath = File::Spec->catpath( @_ );
    print "\$goodpath = " . $goodpath . "\n";
}

sub DirSlurper {
    shift;
    my @files = File::DirList::list( $_, 'dn', 1, 1, 0 );
    return @files;
}
sub FileRetriever {
    my $files = File::Next::files( shift );
    my @dirlist;

    while ( defined ( my $file = $files->() ) ) {
        push ( @dirlist, $file );
    }

    return @dirlist;
}

sub Dirstruction {
	$counter++;
	my @tree;
	my $root = shift; #100001, etc.
	my $outerroot = $outer . "/" . $root; # /Users/eyoung/folderstructure/mvm/100001, etc.
	make_path( $outerroot, {verbose => 0, mode => 0744, error => \my $err} );
	my $docs = $outerroot . "/docs";
	push ( @tree, $docs );
	my $pics = $outerroot . "/pics";
	push ( @tree, $pics );
	my $sspics = $pics . "/survey";
	push ( @tree, $sspics );
	my $servicepics = $pics . "/service";
	push ( @tree, $servicepics );
	my $installpics = $pics . "/install";
	push ( @tree, $installpics );

	foreach my $tdir ( @tree ) {
		make_path( $tdir, {verbose => 0, mode => 0744, error => \my $err} );
	}

	if ( $counter % 100 == 0 ) {
		#print "$tdir \n";
		print "Working...\n";
	}

}
1;