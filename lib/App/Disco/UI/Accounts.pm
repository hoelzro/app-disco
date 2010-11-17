package App::Disco::UI::Accounts;

use Gtk2;
use Gtk2::Gdk::Keysyms;
use Moose;

our $VERSION = '0.01';

has window => (
    is       => 'ro',
    isa      => 'Gtk2::Window',
    init_arg => undef,
    default  => sub {
        return Gtk2::Window->new('toplevel');
    },
    handles  => {
        show => 'show_all',
    },
);

has accounts => (
    is       => 'ro',
    isa      => 'App::Disco::Accounts',
    required => 1,
);

has account_creator => (
    is       => 'ro',
    isa      => 'App::Disco::UI::AccountCreator',
    required => 1,
);

sub BUILD {
    my ( $self ) = @_;

    my $window   = $self->window;
    my $model    = Gtk2::ListStore->new('Glib::String');
    my $accounts = $self->accounts->accounts;
    my $view     = Gtk2::TreeView->new($model);
    my $renderer = Gtk2::CellRendererText->new;
    my $column   = Gtk2::TreeViewColumn->new_with_attributes('Account Name',
        $renderer, text => 0);
    my $buttons       = Gtk2::HBox->new;
    my $add_button    = Gtk2::Button->new_from_stock('gtk-add');
    my $edit_button   = Gtk2::Button->new_from_stock('gtk-edit');
    my $remove_button = Gtk2::Button->new_from_stock('gtk-remove');

    $add_button->signal_connect(clicked => sub {
        $self->account_creator->create;
    });

    $edit_button->signal_connect(clicked => sub {
        my $selection = $view->get_selection;
        $selection = $selection->get_selected;
        ( $selection ) = $model->get($selection, 0);
        $self->account_creator->edit($selection);
    });

    $remove_button->signal_connect(clicked => sub {
        my $selection = $view->get_selection;
        $selection = $selection->get_selected;
        my ( $jid ) = $model->get($selection, 0);
        $model->remove($selection);
        $self->accounts->remove_account($jid);
        $self->accounts->save;
    });

    $view->get_selection->signal_connect(changed => sub {
        my ( $selection ) = @_;

        $selection = $selection->get_selected;

        $edit_button->set_sensitive(defined $selection);
        $remove_button->set_sensitive(defined $selection);
    });

    $window->signal_connect(key_release_event => sub {
        my ( undef, $event ) = @_;

        if($event->keyval == $Gtk2::Gdk::Keysyms{Escape}) {
            $window->hide;
        }
    });

    $view->append_column($column);
    foreach my $account (@$accounts) {
        my $name = exists $account->{name} ? $account->{name} : $account->{jid};
        my $iter = $model->append;
        $model->set($iter, 0 => $name);
    }

    $view->get_selection->set_mode('single');

    $window->set_default_size(600, 400);
    my $box = Gtk2::VBox->new;
    $window->add($box);
    $box->pack_start($view, 1, 1, 0);
    $buttons->pack_start(Gtk2::Label->new, 1, 0, 0);
    $buttons->pack_start($add_button, 0, 0, 0);
    $buttons->pack_start($edit_button, 0, 0, 0);
    $buttons->pack_end($remove_button, 0, 0, 0);
    $box->pack_end($buttons, 0, 0, 0);
}

1;

__END__

=head1 NAME

App::Disco::UI::Accounts

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
