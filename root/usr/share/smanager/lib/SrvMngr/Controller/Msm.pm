package SrvMngr::Controller::Msm;

#----------------------------------------------------------------------
# heading     : Games
# description : Msm
# navigation  : 9000 9100
#----------------------------------------------------------------------
# name   : msm,    method : get,   url : /msm,     ctlact : Msm#main
# routes : end

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use utf8;

use Locale::gettext;
use SrvMngr::I18N;
use SrvMngr qw(theme_list init_session ip_number_or_blank);

use File::Basename;

sub main  {
    my $c = shift;
    my $server_path   = '/opt/msm/servers';
    my $jargroup_path = '/opt/msm/jars';
    
    my @servers;
    my @jargroups;

    # 1. Lister les serveurs actifs dans MSM
    if (-d $server_path) {
        opendir(my $dh, $server_path);
        while (my $dir = readdir($dh)) {
            next if $dir =~ /^\./; # Ignorer . et ..
            if (-d "$server_path/$dir") {
                # Essayer de lire le fichier properties pour extraire le JAR actuel
                my $jar_in_use = "Inconnu";
                my $prop_file = "$server_path/$dir/server.properties";
                if (-f $prop_file) {
                    if (open(my $fh, '<', $prop_file)) {
                        while (<$fh>) {
                            if ($_ =~ /^msm-jar-path=(.+)/) {
                                $jar_in_use = $1;
                                chomp($jar_in_use);
                            }
                        }
                        close($fh);
                    }
                }
                push @servers, { name => $dir, jar => $jar_in_use };
            }
        }
        closedir($dh);
    }

    # 2. Lister les Groupes de JAR et leurs versions disponibles
    if (-d $jargroup_path) {
        opendir(my $jh, $jargroup_path);
        while (my $group = readdir($jh)) {
            next if $group =~ /^\./;
            my $full_group_path = "$jargroup_path/$group";
            
            if (-d $full_group_path) {
                my @jars;
                opendir(my $fjh, $full_group_path);
                while (my $file = readdir($fjh)) {
                    # On ne prend que les fichiers .jar
                    next unless $file =~ /\.jar$/;
                    
                    # Extraction humaine de votre date AAAA-MM-JJ-HH-MM-SS
                    my $date_str = "Origine / Inconnue";
                    if ($file =~ /^(\d{4}-\d{2}-\d{2})-(\d{2})-(\d{2})-(\d{2})-(.+)/) {
                        $date_str = "$1 à $2:$3:$4";
                    }
                    
                    push @jars, { filename => $file, date => $date_str };
                }
                closedir($fjh);
                
                # Trier les JARs du plus récent au plus ancien (ordre alphabétique inverse grâce à la date)
                @jars = sort { $b->{filename} cmp $a->{filename} } @jars;

                push @jargroups, { name => $group, files => \@jars };
            }
        }
        closedir($jh);
    }

    # Passer les données au Template Mojolicious
    $c->stash(
        servers   => \@servers,
        jargroups => \@jargroups,
    );
    $c->render(template  => 'msm');
}

1;

