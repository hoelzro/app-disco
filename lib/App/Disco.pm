package App::Disco;

use strict;
use warnings;

use App::Disco::Accounts;
use App::Disco::UI::Accounts;
use App::Disco::UI::Main;
use App::Disco::Xmpp;

our $VERSION = '0.01';

sub run {
    my ( $self ) = @_;

    my $accounts = App::Disco::Accounts->new;
    $accounts->load;
    my $xmpp = App::Disco::Xmpp->new(accounts => $accounts);
    my $accounts_ui = App::Disco::UI::Accounts->new(accounts => $accounts);
    my $ui = App::Disco::UI::Main->new(
        accounts_ui => $accounts_ui,
        xmpp => $xmpp,
    );

    $ui->run;
}

1;

__END__

=head1 NAME

App::Disco

=head1 SYNOPSIS

  use App::Disco;
  App::Disco->run;

=head1 VERSION

0.01

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
