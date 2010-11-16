package App::Disco::Accounts;

use File::Spec::Functions qw(catfile);
use Moose;
use YAML qw(DumpFile LoadFile);
use namespace::clean -except => 'meta';

our $VERSION = '0.01';

has filename => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $home = (getpwuid $<)[7];
        return catfile($home, '.discorc');
    },
);

has accounts => (
    is         => 'rw',
    isa        => 'ArrayRef',
    default    => sub { [] },
);

has triggers => (
    is       => 'ro',
    isa      => 'HashRef[ArrayRef[CodeRef]]',
    default  => sub { {} },
    init_arg => undef,
);

sub load {
    my ( $self ) = @_;

    my $filename = $self->filename;

    ## fire events
    if(-e $filename) {
        $self->accounts(LoadFile($filename));
    } else {
        $self->accounts([]);
    }
}

sub save {
    my ( $self ) = @_;

    DumpFile($self->filename, $self->accounts);
}

sub add_trigger_callback {
    my ( $self, $type, $callback ) = @_;

    my $callbacks = ($self->triggers->{$type} ||= []);
    push @$callbacks, $callback;
}

sub on_account_added {
    my ( $self, $callback ) = @_;

    $self->add_trigger_callback(added => $callback);
}

sub on_account_removed {
    my ( $self, $callback ) = @_;

    $self->add_trigger_callback(removed => $callback);
}

sub fire_trigger {
    my ( $self, $type, @args ) = @_;

    my $callbacks = $self->triggers->{$type};
    return unless $callbacks;
    foreach (@$callbacks) {
        $_->(@args);
    }
}

sub add_account {
    my ( $self, $account ) = @_;

    push @{ $self->accounts }, $account;
    $self->fire_trigger(added => $account);
}

sub remove_account {
    my ( $self, $account ) = @_;

    my $accounts = $self->accounts;

    my %remove_me = map { $_ => $_ } grep { $_->{jid} eq $account } @$accounts;

    @$accounts = grep {
        ! exists $remove_me{$_}
    } @$accounts;

    foreach (values %remove_me) {
        $self->fire_trigger(removed => $_);
    }
}

1;

__END__

=head1 NAME

App::Disco::Config

=head1 VERSION

0.01

=head1 SYNOPSIS

  use App::Disco::Accounts;

  my $accounts = App::Disco::Accounts->new;
  $accounts->load;
  $accounts->save;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 filename

The filename which the account configuration is loaded from/saved to.

=head2 accounts

The list of account descriptions.

=head1 METHODS

=head2 $accounts->load

Loads account data from disk.

=head2 $accounts->save

Saves account data to disk.

=head2 $accounts->on_account_added($callback)

Register a callback to be called when a new account is
added to the list of existing accounts.

=head2 $accounts->on_account_removed($callback)

Register a callback to be called when a new account is
removed from the list of existing accounts.

=head2 $accounts->add_account($account)

Adds a new account to the list of accounts.

=head2 $accounts->remove_account($account)

Remove an account from the list of accounts.

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
