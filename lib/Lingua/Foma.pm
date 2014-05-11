package Lingua::Foma;
use strict;
use warnings;
use XSLoader;
our $VERSION = '0.01_3';

XSLoader::load('Lingua::Foma', $VERSION);

our $LIB_VERSION = lib_version();


1;


__END__

=pod

=head1 NAME

Lingua::Foma - XS Bindings to the Foma Finite State Morphology Toolkit


=head1 SYNOPSIS

  use Lingua::Foma;

  # Create a new transducer based on regular expressions
  my $fsm = Lingua::Foma->new("{climb}|{jump}|{track}");

  # Modify the transducer using foma operations
  $fsm->unify("{paint}")->concat("{ing}:0");

  # Check some automaton properties
  print $fsm->arc_count;
  # 22

  # Save newly created transducer
  $fsm->save("my_transducer.foma");

  # Load a transducer build with foma
  my $new = Lingua::Foma->load("my_transducer.foma");

  # Iterate through transduced results
  my $i = $new->down("climbing");
  while (my $string = $i->next) {
    print $string, "\n";
    # climb
  };


=head1 DESCRIPTION

L<Foma|https://code.google.com/p/foma/> is a C library for dealing with finite
state automata and transducers - with a main focus on applications in the
field of Finite State Morphology.
This module is an XS binding to the Foma library, supporting a wide range of
API methods. Most of the time all you need is probably L<loading|/load> transducers
created with Foma (using LexC and xfst) and L<translating strings|/APPLICATION METHODS>,
but this library also provides methods to create and modify automata
and retrieve properties.

B<This module is a developer realease - the API may change without notification!>


=head1 ATTRIBUTES


=head2 arc_count

  print $fsm->arc_count;

Return the number of arcs.


=head2 final_count

  print $fsm->final_count;

Return the number of final states.


=head2 is_completed

  if ($fsm->is_completed) {
    print "Complete";
  }
  else if (defined $fsm->is_completed) {
    print "Incomplete";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is complete or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 is_deterministic

  if ($fsm->is_deterministic) {
    print "Deterministic";
  }
  else if (defined $fsm->is_deterministic) {
    print "Nondeterministic";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is deterministic or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 is_epsilon_free

  if ($fsm->is_epsilon_free) {
    print "Has no epsilon arcs";
  }
  else if (defined $fsm->is_epsilon_free) {
    print "Has epsilon arcs";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is free of epsilon arcs or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 is_loop_free

  if ($fsm->is_loop_free) {
    print "Has no loops";
  }
  else if (defined $fsm->is_loop_free) {
    print "Has loops";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is free of loops or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 is_minimized

  if ($fsm->is_minimized) {
    print "Is minimized";
  }
  else if (defined $fsm->is_minimized) {
    print "Is not minimized";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is minimized or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 is_pruned

  if ($fsm->is_pruned) {
    print "Is pruned";
  }
  else if (defined $fsm->is_pruned) {
    print "Is not pruned";
  }
  else {
    print "Status unknown";
  };

Check, if an automaton is pruned or not.
Returns C<undef> if the status is unknown,
otherwise returns either a C<true> or a C<false> value.


=head2 state_count

  print $fsm->state_count;

Return the number of states.


=head1 CONSTRUCTION METHODS

=head2 new

  my $fsm = Lingua::Foma->new('{cat}');

Create a new automaton based on a
L<regular expression|https://code.google.com/p/foma/wiki/RegularExpressionReference>.


=head2 clone

  my $fsm2 = $fsm1->clone;

Create an exact copy of a finite state transducer.


=head1 AUTOMATON METHODS

Automaton methods modify existing automata.
They are destructive, meaning that the invocant transducer
will be modyfied without a copy.
All automaton methods return their invocant to make them easily chainable.


=head2 unify

  # Regular Expression: A | B

  my $fsm_1 = Lingua::Foma->new('{climb}');
  my $fsm_2 = Lingua::Foma->new('{jump}');

  # Unify one transducer with another
  $fsm_1 = $fsm_1->unify($fsm_2);
  # Regex: {climb}|{jump}

  # Unify multiple automata
  $fsm_1->unify('{check}', '{restrict}');
  # Regex: {climb}|{jump}|{check}|{restrict}

Unify multiple finite state automata.
The result may be nondeterministic and nonminimal.
Automata are accepted as L<Lingua::Foma> objects or as regular expressions.
Returns the invocant for chaining.


=head2 concat

  # Regular Expression: A B

  my $fsm_1 = Lingua::Foma->new('{climb}');
  my $fsm_2 = Lingua::Foma->new('{ing}');

  # Concatenate one transducer with another
  $fsm_1 = $fsm_1->concat($fsm_2);
  # Regex: {climbing}

  # Concat multiple automata
  $fsm_1->concat('{tool}', 's');
  # Regex: {climbingtools}


Concatenate multiple finite state automata.
The result may be nondeterministic and nonminimal.
Automata are accepted as L<Lingua::Foma> objects or as regular expressions.
Returns the invocant for chaining.


=head1 I/O METHODS

The supported file format for loading and saving is the binary format
of Foma.

=head2 load

  my $fsm = Lingua::Foma->load("my_automaton.foma");

Load an automaton by passing a filename.
Automata can be saved using L<save|/save>.

I<Files with multiple transducers are currently not supported.>

=head2 save

  $fsm = $fsm->save("may_automaton.foma");

Save an automaton by passing a filename.
Automata can be loaded using L<load|/load>.
Returns the invocant for chaining.


=head1 APPLICATION METHODS

=head2 up

  # Get all interpretation of "climbing"
  my @words = $fsm->up("climbing");

  # Iterate over all interpretations
  my $i = $fsm->up("climbing");
  while (my $string = $i->next) {
    print $string, "\n";
  };

Apply a word through the transducer from the lower language
into the upper language.
In an array context returns all possible interpretations.
In a scalar context returns an L<Iterator|/ITERATOR METHODS>.


=head2 down

  # Get all interpretation of "climb"
  my @words = $fsm->down("climb");

  # Iterate over all interpretations
  my $i = $fsm->down("climb");
  while (my $string = $i->next) {
    print $string, "\n";
  };

Apply a word through the transducer from the upper language
into the lower language.
In an array context returns all possible interpretations.
In a scalar context returns an L<Iterator|/ITERATOR METHODS>.


=head1 ITERATOR METHODS

All L<application methods|/APPLICATION METHODS> return
an iterator object to iterate over results.
The iterator object provides the following methods.


=head2 next

  # Create an iterator object
  my $iter = $fsm->up("tree");

  # Iterate over all results
  while (my $string = $iter->next) {
    print $string, "\n";
  };

Returns the current matching result and forwards the
iterator pointer to the next.
Will return C<undef> if no further result can be found.


=head1 KNOWN BUGS AND CAVEATS

Currently an iterator may loose a corresponding
transducer, if the transducer is modified by a
destructive operation. Operations involving
the modification of transducers during iteration
should therefore be avoided.

There are major leaks when saving and loading
transducers.

As the bundled Foma library is not modyfied,
we ship the attributed bugs
(L<"many"|https://code.google.com/p/foma/source/browse/trunk/foma/README>)
as well.


=head1 AVAILABILITY

  https://github.com/Akron/Lingua-Foma


=head1 COPYRIGHT AND LICENSE

=head2 Lingua::Foma

Copyright (C) 2014, L<Nils Diewald|http://nils-diewald.de/>.

This program is free software, you can redistribute it and/or
modify it under the terms of the
L<GNU General Public License version 2|https://www.gnu.org/licenses/gpl-2.0.txt>.


=head2 Foma 0.9.17alpha (bundled)

Copyright (C) 2008-2012, Mans Hulden.

Licensed under the terms of the
L<GNU General Public License version 2|https://www.gnu.org/licenses/gpl-2.0.txt>.


=cut
