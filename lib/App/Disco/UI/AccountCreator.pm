package App::Disco::UI::AccountCreator;

use Moose;

use App::Disco::Accounts;

our $VERSION = '0.01';

has accounts => (
    is       => 'ro',
    isa      => 'App::Disco::Accounts',
    required => 1,
);

use feature 'say';

sub create {
    my ( $self ) = @_;

    say 'creating an account';
}

sub edit {
    my ( $self, $account ) = @_;

    say 'editing an account';
}

1;

__END__

=head1 NAME

App::Disco::UI::AccountCreator

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
