use strict;
use warnings;
use feature 'say';
use AnyEvent;
use AnyEvent::IRC::Client;
use Encode;
use FindBin;
use Config::PL;


my $channel = "#test";

my $c   = AnyEvent->condvar;
my $irc = new AnyEvent::IRC::Client;

my $bot_nickname = 'pchan';
my $conf         = config_do 'config.pl';

$irc->enable_ssl;

$irc->connect(
    $conf->{host},
    $conf->{port},
    {
        nick     => $bot_nickname,
        password => $conf->{password},
    }
);

$irc->send_srv( "JOIN", $channel );
$irc->reg_cb( connect    => sub { print "connected\n" } );
$irc->reg_cb( registered => sub { print "registered\n"; } );
$irc->reg_cb( disconnect => sub { print "disconnect\n"; } );

my $timer;
$timer = AnyEvent->timer(
    after    => 1, # 秒間まってからループ開始
    interval => 60*60*3, # 秒数ごとにやる
    cb       => sub {
        my $now = DateTime->now( time_zone => 'Asia/Tokyo')->hour;
        if ( $now >= 10 && $now <= 20 ) {
            $irc->send_chan( $channel, "PRIVMSG", $channel, 'qchan all' );
        }
    }
);

$c->recv;
