#!/usr/bin/env perl
# perl -MTest::Valgrind t/foma.t
use strict;
use warnings;

use lib 'blib/lib', 'blib/arch';
use File::Temp qw/:POSIX tmpnam/;

use Test::More;
use Lingua::Foma;

# Synopsis
ok(my $fsm = Lingua::Foma->new("{climb}|{jump}|{track}"), 'New regex');

# Modify the transducer using foma operations
ok($fsm->unify("{paint}")->concat("{ing}:0"), 'Unification and Concatenation');

# Check some automaton properties
is($fsm->arc_count, 22, 'Arc-Count');

my $temp = tmpnam();

ok(my $x = $fsm->save($temp), 'Save fst');

ok(my $new = Lingua::Foma->load($temp), 'Load fst');

# Iterate through transduced results
my $i = $new->down("climbing");
is(scalar $i->next, 'climb', 'Transduced');
ok(!$i->next, 'No more words');

done_testing;
