#!/usr/bin/perl 

use strict;
use warnings;

use LWP::Simple;
use HTML::TreeBuilder;
use XML::RSS;

use Readonly;

# define our feeds
Readonly our $FEEDS => {
                        i386    => {
                                    title   => 'rpmforge-i386',
                                    link    => 'http://mirror.hmdc.harvard.edu/rpmforge/el5/i386/rpmforge/RPMS/',
                                    description => 'RPMforge - i386 packages',
                                   },
                        x86_64  => {
                                    title   => 'rpmforge-x86_64',
                                    link    => 'http://mirror.hmdc.harvard.edu/rpmforge/el5/x86_64/rpmforge/RPMS/',
                                    description => 'RPMforge - x86_64 packages',
                                   },
                       };
                        
# iterate over feeds
foreach my $feed ( keys( %{$FEEDS} ) ) {

    # download the html
    my( $feedurl ) = $FEEDS->{$feed}->{link};
    my( $html ) = get( $feedurl . '?C=M;O=D')
        or next;

    # instantiate the RSS feed
    my( $rss ) = XML::RSS->new( version => '1.0' );

    # make a channel
    $rss->channel( 
                  %{$FEEDS->{$feed}},
                  syn => {
                      updatePeriod      => 'daily',
                      updateFrequency   => '1',
                      updateBase        => '2010-03-13T04:05:00-05:00',
                  },
                 );

    # instantiate the HTML parser
    my( $tree ) = HTML::TreeBuilder->new_from_content( $html );

    # all we want is the <pre>
    my( @rpms ) = $tree->look_down( '_tag', 'a',
                                    sub { 
                                         $_[0]->as_text =~ /\.rpm$/ 
                                    },
                                  );
    while ( @rpms ) {
    
        my( $rpm ) = shift( @rpms );
        my( $title ) = $rpm->as_text;
        my( $link ) = $feedurl . $title;
        $rss->add_item( title => $title, link => $link );
    }

    # clean up
    $tree->delete;
    $rss->save( $feed . '.rss' );
}
