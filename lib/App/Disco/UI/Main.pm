package App::Disco::UI::Main;

use Gtk2 '-init';
use Gtk2::Gdk::Keysyms;
use Moose;

our $VERSION = '0.01';

has accounts_ui => (
    is       => 'ro',
    isa      => 'App::Disco::UI::Accounts',
    required => 1,
);

sub BUILD {
    my ( $self ) = @_;

    my $accel_group = Gtk2::AccelGroup->new;
    my $window = Gtk2::Window->new('toplevel');
    $window->add_accel_group($accel_group);
    $window->set_default_size(600, 400);
    $window->signal_connect(destroy => sub {
        Gtk2->main_quit;
    });
    $window->signal_connect('key-release-event', sub {
        my ( undef, $event ) = @_;

        if($event->keyval == $Gtk2::Gdk::Keysyms{Escape}) {
            $window->destroy;
        }
    });
    my $menubar = Gtk2::MenuBar->new;
    my $accounts_item = Gtk2::MenuItem->new('Accounts');
    my $accounts_menu = Gtk2::Menu->new;
    my $account_accounts_item = Gtk2::MenuItem->new('_Accounts');
    my $quit_item = Gtk2::MenuItem->new('_Quit');
    $menubar->append($accounts_item);
    $accounts_item->set_submenu($accounts_menu);
    $accounts_menu->append($account_accounts_item);
    $accounts_menu->append(Gtk2::SeparatorMenuItem->new);
    $accounts_menu->append($quit_item);
    $account_accounts_item->add_accelerator(activate => $accel_group,
        $Gtk2::Gdk::Keysyms{'a'}, 'control-mask', 'visible');
    $quit_item->add_accelerator(activate => $accel_group,
        $Gtk2::Gdk::Keysyms{'q'}, 'control-mask', 'visible');

    $account_accounts_item->signal_connect(activate => sub {
        $self->accounts_ui->show;
    });

    $quit_item->signal_connect(activate => sub {
        $window->destroy;
    });
    my $box = Gtk2::VBox->new;
    $box->pack_start($menubar, 0, 0, 0);
    $window->add($box);
    $window->show_all;
}

sub run {
    Gtk2->main;
}

1;

__END__

=head1 NAME

App::Disco::UI::Main

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
