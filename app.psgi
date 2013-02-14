#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Web::Scraper;
use Config::Pit;
use WWW::Mechanize;
use URI::Escape;
use Data::Dumper;
use Encode;
my $retry = 0;

my $mech;
my $word = "1000user 東方";
my $count = count();

my $app = sub {
    my $env  = shift;
    my $retrieve = retrieve();
    my $url = ($retrieve) ? "http://www.pixiv.net".$retrieve : "http://www.google.co.jp/";
    my $html = sprintf(<<HTML, $url);
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0;url=%s">
  </head>
</html>
HTML
    return [
        200,
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
};

sub mech {
    my (%args) = @_;
    my $login_url  = "https://www.secure.pixiv.net/login.php";
    my $mypage_url = "http://www.pixiv.net/mypage.php";
    if (!$mech || $args{force}) {
        die "over retry" if (10 <= $retry);
        warn "retry: ".++$retry if($args{force});
        $mech = WWW::Mechanize->new();
        $mech->get($login_url);
        $mech->submit_form(
            form_number => 2,
            fields      => pit_get("www.pixiv.net", require => {
                "pixiv_id" => "your pixiv_id",
                "pass"     => "your pass",
            }),
        );
        die "login faild" if ($login_url eq $mech->uri());
        return $mech;
    }
    $mech->get("http://www.pixiv.net/mypage.php");
    mech(force => 1) if ($mypage_url ne $mech->uri());
    return $mech;
}

sub url { "http://www.pixiv.net/search.php?word=".uri_escape_utf8($word) }

sub count {
    my $mech = mech();
    $mech->get(url());
    my $scraper = scraper {
        process "div.column-title-container span.count-badge", count => 'TEXT';
    };
    my $res = $scraper->scrape($mech->content());
    $res->{count} =~ s/件//;
    return $res->{count};
}

sub retrieve {
    my $page = int($count / 20) + (($count % 20 == 0) ? 0 : 1);
    my $target_page = int(rand($page)) + 1;
    my $mech = mech();
    $mech->get(url()."&p=$target_page");
    my $scraper = scraper {
        process "li.image-item > a:first-child", 'url[]' => '@href';
    };
    my $res = $scraper->scrape($mech->content());
    return $res->{url}->[int(rand(@{$res->{url}}))];
}
