package App::Disco::Xmpp;

use AnyEvent::XMPP::Client;
use Moose;

our $VERSION = '0.01';

has accounts => (
    is       => 'ro',
    isa      => 'App::Disco::Accounts',
    required => 1,
);

has client => (
    is       => 'ro',
    isa      => 'AnyEvent::XMPP::Client',
    init_arg => undef,
    default  => sub {
        return AnyEvent::XMPP::Client->new;
    },
);

sub handle_account_added {
    my ( $self, $account ) = @_;

    my $client = $self->client;

    $client->add_account(
        $account->{jid},
        $account->{password},
        $account->{domain},
        $account->{port},
    {
        initial_presence => undef,
        resource         => 'disco',
    });
}

sub handle_account_removed {
    my ( $self, $account ) = @_;

    my $client = $self->client;

    my $existing_account = $client->get_account($account->{jid});
    if($existing_account) {
        $client->remove_account($account->{jid});
    }
}

sub BUILD {
    my ( $self ) = @_;

    my $client = $self->client;
    my $accounts = $self->accounts;
    foreach my $account (@{ $accounts->accounts } ) {
        $self->handle_account_added($account);
    }

    $accounts->on_account_added(sub {
        my ( $account ) = @_;

        $self->handle_account_added($account);
    });

    $accounts->on_account_removed(sub {
        my ( $account ) = @_;

        $self->handle_account_removed($account);
    });

    $client->start;
}

1;

__END__

=head1 NAME

App::Disco::Xmpp

=head1 VERSION

0.01

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=head1 AUTHOR

Rob Hoelz, C<< rob at hoelz.ro >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-App-Disco at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Disco>. I will
be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2010 Rob Hoelz.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<disco>

=cut
