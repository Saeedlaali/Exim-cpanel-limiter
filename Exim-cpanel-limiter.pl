#	Start  //////////////////////////////////////////////
#	Codes should be write in get_message_sender sub in /etc/exim.pl.local
#	Create and write in ServerPars , Saeed la'li 

sub find_uid
{
        my $uid = Exim::expand_string('$originator_uid');
	    my $username = getpwuid($uid);
        my $auth_id = Exim::expand_string('$authenticated_id');
        my $work_path = $ENV{'PWD'};

	if ($username eq "apache" || $username eq "nobody" || $username eq "webapps")
	{
		$uid = find_uid_apache($work_path);
		if ($uid != -1) { return $uid; }
	}
	
	$uid = find_uid_auth_id($auth_id);
	if ($uid != -1) { return $uid; }

	return find_uid_sender;
}

sub find_uid_sender
{
	my $sender_address = Exim::expand_string('$sender_address');

	my ($user,$domain) = split(/\@/, $sender_address);

	my $primary_hostname = Exim::expand_string('$primary_hostname');
	if ( $domain eq $primary_hostname )
	{
		@pw = getpwnam($user);
		return $pw[2];
	}

	my $username = get_domain_owner($domain);

	if ( (@pw = getpwnam($username))  )
	{
		return $pw[2];
	}

	return -1;
}

sub get_domain_owner
{
	my ($domain) = @_;
	my $username="";
	# masire domain ha be hamraye username  
	open(DOMAINOWNERS,"/etc/trueuserdomains");
	while (<DOMAINOWNERS>)
	{
		$_ =~ s/\n//;
		my ($dmn,$usr) = split(/: /, $_);
		if ($dmn eq $domain)
		{
			close(DOMAINOWNERS);
			return $usr;
		}
	}
	close(DOMAINOWNERS);

	return -1;
}

sub uid_exempt
{
        my ($uid) = @_;
        if ($uid == 0) { return 1; }

        my $name = getpwuid($uid);
        if ($name eq "root") { return 1; }
        if ($name eq "apache") { return 1; }

        return 0;
}

sub find_uid_apache
{
	my ($work_path) = @_;
	my @pw;
	
	@dirs = split(/\//, $work_path);
	foreach $dir (@dirs)
	{

		if ( (@pw = getpwnam($dir))  )
		{
			if ($work_path =~/^$pw[7]/)
			{
				return $pw[2];
			}
		}
	}
	return -1;
}

sub find_uid_auth_id
{

	my ($auth_id) = @_;
	my $unixuser = 1;
	my $domain = "";
	my $user = "";
	my $username = $auth_id;
	my @pw;

	if ($auth_id =~ /\@/)
	{
		$unixuser = 0;
		($user,$domain) = split(/\@/, $auth_id);
		if ($domain eq "") { return "-1"; }
        }

	if (!$unixuser)
	{
	
		my $u = get_domain_owner($domain);;
		if ($u != -1)
		{
			$username = $u;
		}
	}

	if ( (@pw = getpwnam($username))  )
	{
		return $pw[2];
	}

	return -1;
}
	
sub get_message_sender 
{

    my $cmd = 'exiqgrep -z -i | xargs exim -Mrm';
    # my $auth = Exim::expand_string('$authenticated_id');
	my $sender_address 	= Exim::expand_string('$sender_address');
	my $authenticated_id	= Exim::expand_string('$authenticated_id');
	my $sender_host_address	= Exim::expand_string('$sender_host_address');
	my $mid 		= Exim::expand_string('$message_id');
	my $message_size	= Exim::expand_string('$message_size');
	my $local_part		= Exim::expand_string('$local_part');
	my $domainsend		= Exim::expand_string('$sender_address_domain');
	my $domain		= Exim::expand_string('$domain');
	my $timestamp		= time();
	my $is_retry = 0;
	
	#peyda kardane user ba estefade az tavabe'e ezafe shode 
	
	$uid = find_uid();

	if (uid_exempt($uid)) { return "yes"; }

	my $name="";

	#emale mahdudiyat 
	
	$name = getpwuid($uid);

	if (!defined($name))
	
	{
		#ezafe shodan be surat unknown dar surate verify nabudan va jelo giri az ersale fake auth
		
		$name = "unknown";
	}
	
# /tmp/exim path to save rep 

    mkdir("/tmp/exim/");
    my $btime = time();
	
# Start of a new user to create folder and count 

    if (! -d "/tmp/exim/$name") {
        mkdir("/tmp/exim/$name");
        my $sstime = $btime - ($btime % 3600);
		my $ddtime =  $btime - ($btime % 86400);
		
        open(SLIMIT, ">/tmp/exim/$name/start");
        print SLIMIT $sstime;
        close(SLIMIT);
		
		open(DLIMIT, ">/tmp/exim/$name/dstart");
		print DTIME $ddtime;
		close(DTIME);
		
        open(SCOUNT, ">/tmp/exim/$name/count");
        print SCOUNT 1;
        close(SCOUNT);
		
		open(DCOUNT, ">/tmp/exim/$name/dcount");
        print DCOUNT 1;
        close(DCOUNT);

        open(SLAST, ">/tmp/exim/$name/last");
        print SLAST $btime;
        close(SLAST);
		
		open(DLAST, ">/tmp/exim/$name/dlast");
        print DLAST $btime;
        close(DLAST);

    } else {
        my $bcount = 0;
        open(SCOUNT, "/tmp/exim/$name/count");
        $bcount = int(<SCOUNT>);
        close(SCOUNT);
		
		my $dcount = 0;
        open(DCOUNT, "/tmp/exim/$name/dcount");
        $dcount = int(<DCOUNT>);
        close(DCOUNT);

        my $blast = 0;
        open(SLAST, "/tmp/exim/$name/last");
        $blast = int(<SLAST>);
        close(SLAST);

		my $dlast = 0;
        open(DLAST, "/tmp/exim/$name/dlast");
        $dlast = int(<DLAST>);
        close(DLAST);
		
        my $bstart = 0;
        open(SLIMIT, "/tmp/exim/$name/start");
        $bstart = int(<SLIMIT>);
        close(SLIMIT);
		
		my $dstart = 0;
        open(DLIMIT, "/tmp/exim/$name/dstart");
        $dstart = int(<DLIMIT>);
        close(DLIMIT);

		    if ($btime >= $dstart + 86400) {
            my $dtime = $btime - ($btime % 86400);
			
                open(DLIMIT, ">/tmp/exim/$name/dstart");
                print DLIMIT $dtime;
                close(DLIMIT);
                             
# Start save report file for each hour 
# Directory report : /tmp/exim/report
# Save report file in : /tmp/exim/report/$auth

				mkdir("/tmp/exim/report");
                open(DFFM, ">>/tmp/exim/report/$name");
                print(DFFM "$dcount \n");
                close(DFFM);
				
# Replace 1 in count file to recount timer 
				
                open(DCOUNT, ">/tmp/exim/$name/dcount");
                print DCOUNT 1;
                close(DCOUNT);
				
				
                open(DEMD, ">/etc/blockeddomains");
                print DEMD "1 \n";
                close(DEMD);

} else {

# email limit numbers

    if ($dcount >= 1000) {

      open(DCOUNT, ">/tmp/exim/$auth/dcount");
      print DCOUNT $dcount+1;
      close(DCOUNT);

# add domain to /etc/blockeddomains file  
       
	 open(DDDBL, ">>/etc/blockeddomains");
	 print DDDBL "$domainsend \n";
	 close(DDDBL);

# system command  > clean the queue 
	 
        system("$cmd");
		
        die("You reached the mail limit per day.");

            }
                open(DCOUNT, ">/tmp/exim/$name/dcount");
                print DCOUNT $dcount+1;
                close(DCOUNT);

                open(DLAST, ">/tmp/exim/$name/dlast");
                print DLAST $btime;
                close(DLAST);
    }
		
        if ($btime >= $bstart + 3600) {
            my $sstime = $btime - ($btime % 3600);
                open(SLIMIT, ">/tmp/exim/$name/start");
                print SLIMIT $sstime;
                close(SLIMIT);
                             
# Start save report file for each hour 
# Directory report : /tmp/exim/report
# Save report file in : /tmp/exim/report/$auth

				mkdir("/tmp/exim/report");
                open(FFM, ">>/tmp/exim/report/$auth");
                print(FFM "$bcount \n");
                close(FFM);
				
# Replace 1 in count file to recount timer 
				
                open(SCOUNT, ">/tmp/exim/$name/count");
                print SCOUNT 1;
                close(SCOUNT);
				
				
                open(REMD, ">/etc/blockeddomains");
                print REMD "1 \n";
                close(REMD);

} else {

# email limit numbers

    if ($bcount >= 3) {

      open(SCOUNT, ">/tmp/exim/$auth/count");
      print SCOUNT $bcount+1;
      close(SCOUNT);

# add domain to /etc/blockeddomains file  
       
	 open(ADDBL, ">>/etc/blockeddomains");
	 print ADDBL "$domainsend \n";
	 close(ADDBL);

# system command  > clean the queue 
	 
        system("$cmd");
		
        die("You reached the mail limit per hour.");

            }
                open(SCOUNT, ">/tmp/exim/$name/count");
                print SCOUNT $bcount+1;
                close(SCOUNT);

                open(SLAST, ">/tmp/exim/$name/last");
                print SLAST $btime;
                close(SLAST);
    }


}