package Mojolicious::Plugin::Minion::Admin;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::File 'path';

sub register {
  my ($self, $app) = @_;

  # Static files
  my $resources = path(__FILE__)->sibling('resources');
  push @{$app->static->paths}, $resources->child('public')->to_string;

  # Templates
  push @{$app->renderer->paths}, $resources->child('templates')->to_string;

  # Routes
  my $prefix = $app->routes->any('/minion');
  $prefix->get('/'           => \&_dashboard)->name('minion_dashboard');
  $prefix->get('/stats'      => \&_stats)->name('minion_stats');
  $prefix->get('/jobs'       => \&_jobs)->name('minion_jobs');
  $prefix->get('/job/:id'    => \&_job)->name('minion_job');
  $prefix->get('/workers'    => \&_workers)->name('minion_workers');
  $prefix->get('/worker/:id' => \&_worker)->name('minion_worker');

  return $prefix;
}

sub _dashboard {
  my $c = shift;
  $c->render('minion/dashboard');
}

sub _job {
  my $c = shift;
  $c->render('minion/job');
}

sub _jobs {
  my $c = shift;
  my $jobs = $c->minion->backend->list_jobs(0, 100);
  $c->render('minion/jobs', jobs => $jobs);
}

sub _stats {
  my $c = shift;
  $c->render(json => $c->minion->stats);
}

sub _worker {
  my $c = shift;
  $c->render('minion/worker');
}

sub _workers {
  my $c = shift;
  my $workers = $c->minion->backend->list_workers(0, 100);
  $c->render('minion/workers', workers => $workers);
}

1;
