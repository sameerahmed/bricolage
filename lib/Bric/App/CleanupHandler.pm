package Bric::App::CleanupHandler;

=head1 NAME

Bric::App::CleanupHandler - Cleans up at the end of a request.

=head1 VERSION

$Revision: 1.11.2.1 $

=cut

# Grab the Version Number.
our $VERSION = (qw$Revision: 1.11.2.1 $ )[-1];

=head1 DATE

$Date: 2003-08-04 17:16:05 $

=head1 SYNOPSIS

  <Perl>
  use lib '/usr/local/bricolage/lib';
  </Perl>
  PerlModule Bric::App::Handler
  PerlModule Bric::App::AccessHandler
  PerlModule Bric::App::CleanupHandler
  PerlFreshRestart    On
  DocumentRoot "/usr/local/bricolage/comp"
  <Directory "/usr/local/bricolage/comp">
      Options Indexes FollowSymLinks MultiViews
      AllowOverride None
      Order allow,deny
      Allow from all
      SetHandler perl-script
      PerlHandler Bric::App::Handler
      PerlAccessHandler Bric::App::AccessHandler
      PerlCleanupHandler Bric::App::CleanupHandler
  </Directory>

=head1 DESCRIPTION

This module handles the cleanup phase of an Apache request. It logs all events
to the database (which in turn send any alerts), syncs the session data, and
clears out the request cache.

=cut

################################################################################
# Dependencies
################################################################################
# Standard Dependencies
use strict;

################################################################################
# Programmatic Dependences
use Apache::Constants qw(OK);
use Bric::App::Session;
use Bric::App::Event qw(commit_events);
use Bric::Util::DBI qw(:trans);

################################################################################
# Inheritance
################################################################################

################################################################################
# Function and Closure Prototypes
################################################################################

################################################################################
# Constants
################################################################################

################################################################################
# Fields
################################################################################
# Public Class Fields

################################################################################
# Private Class Fields

################################################################################

################################################################################
# Instance Fields

################################################################################
# Class Methods
################################################################################

=head1 INTERFACE

=head2 Constructors

NONE.

=head2 Destructors

NONE.

=head2 Public Class Methods

NONE.

=head2 Public Functions

=over 4

=item my $status = handler()

Handles the apache request.

B<Throws:> None - the buck stops here!

B<Side Effects:> NONE.

B<Notes:> NONE.

=cut

sub handler {
    my $r = shift;
    eval {
	# Commit events (and send alerts).
	begin(1);
	commit_events();
	commit(1);
    };
    # Log any errors.
    if (my $err = $@) {
	rollback(1);
	$r->log->error($err);
    }

    eval {
	# Sync the user's session data.
	Bric::App::Session::sync_user_session($r);
    };
    # If there's a problem with this (unlikely!), then we're hosed. Apache will
    # hang and need to be rebooted.
    $r->log->error($@) if $@;
    # Bail (this actually isn't required, but let's be consistent!).
    return OK;
}


=back

=head1 PRIVATE

=head2 Private Class Methods

NONE.

=head2 Private Instance Methods

NONE.

=head2 Private Functions

NONE.

=cut

1;
__END__

=head1 NOTES

NONE.

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Bric|Bric>

=cut
