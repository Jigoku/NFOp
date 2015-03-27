#!/usr/bin/env perl
# nfop
# A gtk2/perl based nfo viewer
#
# Copyright (C) 2015 Ricky K. Thomson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# u should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use utf8;

use Gtk2 qw(init);
use FindBin qw($Bin); 
use Encode qw(encode decode);

my $version	= "0.01";
my $xml	= $Bin . "/data/gui.xml";

if ( ! -e $xml ) { die "** Interface: '$xml' $!"; }

my (
	$builder, 
	$window, 
	$filechooser,
	$textview,
	$fontbutton,
	$buffer,
);



main();

gtk_main_quit();


sub main {
	$builder = Gtk2::Builder->new();
	
	# load glade XML
	$builder->add_from_file( $xml );

	# get top level object
	$window = $builder->get_object( 'window' );
	$builder->connect_signals( undef );

	# object definitions
	$filechooser = $builder->get_object( 'filechooserdialog' );
	$textview = $builder->get_object( 'textview' );
	$fontbutton = $builder->get_object('fontbutton');
	$buffer = $textview->get_buffer;
	
	# appplication defaults
	$window->set_default_size(425, 450);

	#font
	set_default_font("Monospace 7");
	
	#foreground
	$builder->get_object( 'colourbutton_fg' )->set_color(
		Gtk2::Gdk::Color->new (0xf000,0xf000,0xf000)
	);
	
	#background
	$builder->get_object( 'colourbutton_bg' )->set_color(
		Gtk2::Gdk::Color->new (0x0000,0x0000,0x0000)
	);

	set_bg_colour();
	set_fg_colour();

	# draw the window
	$window->show_all();

	# main loop
	Gtk2->main();
}

sub on_about_clicked {
	# launch about dialog
	my $about = $builder->get_object( 'aboutdialog' );
	$about->run;
	# make sure it goes away when closed/x
	$about->hide;
}

sub on_openfile_clicked {
	my $filternfo = Gtk2::FileFilter->new();
	$filternfo->add_pattern("*.nfo");
	$filternfo->set_name("nfo files");

	my $filterall = Gtk2::FileFilter->new();
	$filterall->add_pattern("*");
	$filterall->set_name("all");
	

	$filechooser->add_filter($filternfo);
	$filechooser->add_filter($filterall);
	$filechooser->run;
	$filechooser->hide;
}

sub on_button_openfile_clicked($) {
	$filechooser->hide;
	
	my $text;
	
	open FILE, "<:encoding(CP437)", $filechooser->get_filename or die $!;
	
	while (<FILE>){
		$text .= $_;
	}
	
	close FILE;
	my $buffer = $textview->get_buffer;
	$buffer->set_text($text);
}

sub on_fontbutton_font_set {
	set_textview_font($fontbutton->get_font_name);
}

sub set_textview_font($) {
	$textview->modify_font(	
		Gtk2::Pango::FontDescription->from_string(
			shift
		)
	);
}

sub set_bg_colour {
	my $colour = $builder->get_object( 'colourbutton_bg' )->get_color->to_string;
	
	my $red = substr($colour, 1, 4);
	my $green = substr($colour, 5, 4);
	my $blue = substr($colour, 9, 4);
	
	# background
	$textview->modify_base(
		'normal',
		Gtk2::Gdk::Color->new(hex($red),hex($green),hex($blue))
	);
	
	# padding
	$textview->modify_bg(
		'normal',
		Gtk2::Gdk::Color->new(hex($red),hex($green),hex($blue))
	);
	
}

sub set_fg_colour {
	my $colour = $builder->get_object( 'colourbutton_fg' )->get_color->to_string;
	
	my $red = substr($colour, 1, 4);
	my $green = substr($colour, 5, 4);
	my $blue = substr($colour, 9, 4);
	
	print "foreground colour not implemented. \n";

}

sub get_colour($) {
	my $object = $builder->get_object( shift );
	return $object->get_color;
}

sub set_default_font($) {
	my $font = shift;
	$fontbutton->set_font_name($font);
	set_textview_font($font);
}

sub gtk_main_quit {
	 $window->destroy; Gtk2->main_quit();
	 exit(0);
}


#EOF#


