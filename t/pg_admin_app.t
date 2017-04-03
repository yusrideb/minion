use Mojo::Base -strict;

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

use Mojolicious::Lite;
use Test::Mojo;

# Isolate tests
require Mojo::Pg;
my $pg = Mojo::Pg->new($ENV{TEST_ONLINE});
$pg->db->query('drop schema if exists minion_admin_test cascade');
$pg->db->query('create schema minion_admin_test');
plugin Minion => {Pg => $ENV{TEST_ONLINE}};
app->minion->backend->pg->search_path(['minion_admin_test']);

plugin 'Minion::Admin';

my $t = Test::Mojo->new;

$t->get_ok('/minion')->status_is(200)->content_like(qr/Dashboard/);

# Clean up once we are done
$pg->db->query('drop schema minion_admin_test cascade');

done_testing();
