use strict;
use Unix::Processors;
use Cwd 'getcwd';

my $cpus = Unix::Processors->new->max_online;

my @cmd = ([qw'plackup -s Starman -E production --listen /dev/shm/app.sock --workers=', $cpus, qw'-a app.psgi'],
           [qw'nginx -c nginx.conf -p', getcwd]);

my @child;
for (@cmd) {
    if ((my $pid = fork) > 0) { push @child, $pid }
    elsif (defined $pid) { exec @$_ }
    else { die 'fork failed' }
}

# wait childs
$SIG{INT} = $SIG{TERM} = sub { kill TERM => @child; 1 while wait != -1 };
1 while wait != -1;

exit 0;
