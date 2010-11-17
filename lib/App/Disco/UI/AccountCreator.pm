package App::Disco::UI::AccountCreator;

use Gtk2;
use Gtk2::Gdk::Keysyms;
use Moose;

use App::Disco::Accounts;

our $VERSION = '0.01';

my @ui_attributes;

sub _new_entry {
    return Gtk2::Entry->new;
}

use namespace::clean -except => 'meta';

sub has_ui_attr {
    my ( $name, $label, %opts ) = @_;

    $opts{documentation} = $label;
    $opts{is}      = 'ro';
    $opts{isa}     = 'Gtk2::Entry';
    if(my $with_entry = delete $opts{with_entry}) {
        $opts{default} = sub {
            my ( $self ) = @_;

            my $entry = _new_entry;
            $self->$with_entry($entry);
            return $entry;
        };
    } else {
        $opts{default} = \&_new_entry;
    }
    has $name, %opts;

    push @ui_attributes, $name;
}

has window => (
    is      => 'ro',
    isa     => 'Gtk2::Window',
    default => sub {
        return Gtk2::Window->new('toplevel');
    },
);

has_ui_attr 'jid', 'JID';
has_ui_attr 'password', 'Password', (
    with_entry => sub {
        my ( undef, $entry ) = @_;

        $entry->set_visibility(0);
    },
);

has_ui_attr 'username', 'Username';
has_ui_attr 'domain', 'Domain';
has_ui_attr 'host', 'Host';
has_ui_attr 'port', 'Port';

has accounts => (
    is       => 'ro',
    isa      => 'App::Disco::Accounts',
    required => 1,
);

sub BUILD {
    my ( $self ) = @_;

    my $window = $self->window;

    $window->signal_connect(key_release_event => sub {
        my ( undef, $event ) = @_;

        if($event->keyval == $Gtk2::Gdk::Keysyms{Escape}) {
            $window->hide;
        }
    });

    my $box = Gtk2::VBox->new(1, 0);
    $window->add($box);

    my $meta = __PACKAGE__->meta;
    my @attributes = map { $meta->get_attribute($_) } @ui_attributes;

    foreach (@attributes) {
        next unless $_->documentation;

        my $hbox = Gtk2::HBox->new(1, 0);
        $box->pack_start($hbox, 0, 0, 0);
        $hbox->pack_start(Gtk2::Label->new($_->documentation . ':'), 0, 0, 0);
        $hbox->pack_end($_->get_value($self), 0, 0, 0);
    }
}

sub show_ui {
    my ( $self, %opts ) = @_;

    my $window = $self->window;
    $window->set_title($opts{title});
    my $meta = __PACKAGE__->meta;
    my @attributes = $meta->get_all_attributes;
    foreach (@attributes) {
        next unless $_->documentation;

        my $entry = $_->get_value($self);
        my $value = '';
        if(exists $opts{$_->name}) {
            $value = $opts{$_->name};
        }
        $entry->set_text($value);
    }

    $window->show_all;
}

sub create {
    my ( $self ) = @_;

    $self->show_ui(
        title => 'Create an account',
    );
}

sub edit {
    my ( $self, $account ) = @_;

    $account = $self->accounts->get_account($account);
    $self->show_ui(
        title => 'Editing ' . $account->{jid},
        %$account,
    );
}

__PACKAGE__->meta->make_immutable;
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
