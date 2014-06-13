#!/usr/bin/perl

use strict;
use warnings;

use Gtk2 '-init';
use Gtk2::GladeXML;

my %english;
my %spanish;
my $espanol = 1;

#-----------------------------------------------------------
#  Reading dictionary content
#-----------------------------------------------------------
open(my $in, "<", "dictionary.txt") or die "Cannot open dictionary file.\n";

while (<$in>) {
	my @word = split(" ", $_);
	$spanish{uc($word[0])} = uc($word[1]);
	$english{uc($word[1])} = uc($word[0]);
}

close $in;

#-----------------------------------------------------------
#  Signal events
#-----------------------------------------------------------

# Dialog
my $object = Gtk2::GladeXML->new('traductor.glade');
my $dialog = $object->get_widget('dialog1');
$dialog->show_all;
$dialog->signal_connect(destroy => sub {Gtk2->main_quit});

# Exit button
my $quit_button = $object->get_widget('button1');
$quit_button->signal_connect(clicked => sub {Gtk2->main_quit});

# Entry
my $text_box = $object->get_widget('entry1');

# Language options
my $spanish_radio_button = $object->get_widget('radiobutton1');
$spanish_radio_button->signal_connect(toggled => sub {$espanol = not $espanol});

# Clear button
my $clear_button = $object->get_widget('button3');
$clear_button->signal_connect(clicked => sub {$text_box->set_text("")});

# Translate button
my $translate_button = $object->get_widget('button2');
$translate_button->signal_connect(clicked => sub {
	my $title;
	my $label;

	my $palabra = uc($text_box->get_text);

	return if $palabra eq "";

	if ($espanol) {
		$title = "Español a Inglés";

		if (defined $spanish{$palabra}) {
			my $traduccion = $palabra.": ".$spanish{$palabra};
			$label = Gtk2::Label->new($traduccion);
		} else {
			$label = Gtk2::Label->new("Palabra no encontrada: $palabra");
		}
	} else {
		$title = "English to Spanish";

		if (defined $english{$palabra}) {
			my $traduccion = $palabra.": ".$english{$palabra};
			$label = Gtk2::Label->new($traduccion);
		} else {
			$label = Gtk2::Label->new("Palabra no encontrada: $palabra");
		}
	}

	my $msg_box = Gtk2::Dialog->new(
		$title,
		$dialog,
		'destroy-with-parent',
		'Aceptar' => 'ok'
	);

	$msg_box->set_default_size(250, 100);
	$msg_box->get_content_area()->add($label);
	$label->show;
	$msg_box->show_all;
	$msg_box->run;
	$msg_box->destroy;
});

Gtk2->main;
