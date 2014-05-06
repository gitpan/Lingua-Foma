#!/usr/bin/env perl
use strict;
use warnings;

use lib 'blib/lib', 'blib/arch';

use Test::More;
use Lingua::Foma;
use File::Temp qw/:POSIX tmpnam/;

# perl -MTest::Valgrind t/foma.t
# $|++;

# Test for utf8!

is($Lingua::Foma::LIB_VERSION, '0.9.17alpha', 'Version number');

{
  local $SIG{__WARN__} = sub {};
  ok(!(my $net = Lingua::Foma->new("")), 'Create network (fail)');
};

ok(my $net = Lingua::Foma->new("{cat}"), 'Create network ({cat})');

is($net->arc_count, 3, 'Arc count');
is($net->state_count, 4, 'State count');
is($net->final_count, 1, 'Final count');
ok(!(defined $net->is_completed), 'Is completed');
ok($net->is_deterministic, 'Is deterministic');
ok($net->is_epsilon_free, 'Is epsilon free');
ok(!(defined $net->is_loop_free), 'Is loop free');
ok($net->is_minimized, 'Is minimized');
ok($net->is_pruned, 'Is pruned');

ok(my @strings = $net->up("cat"), 'Get array for cat');
is($strings[0], 'cat', 'First string');
is(scalar @strings, 1, 'All strings');
is($net->up("cat")->next, 'cat', 'Get string for cat');

ok($net = Lingua::Foma->new("{cat}:{dog}"), 'Create network {cat}:{dog}');

is($net->arc_count, 3, 'Arc count');
is($net->state_count, 4, 'State count');
is($net->final_count, 1, 'Final count');

is($net->up('dog')->next, 'cat', 'Apply up (net)');
is($net->down('cat')->next, 'dog', 'Apply down (net)');

ok($net = Lingua::Foma->new("{jump}:{check}"), 'Create network {jump}:{climb}');
is($net->up('check')->next, 'jump', 'Apply up');
is($net->down('jump')->next, 'check', 'Apply down');
isnt($net->up('checking')->next, 'jumping', 'Apply down');
isnt($net->down('jumping')->next, 'checking', 'Apply up');

is($net->arc_count, 5, 'Arc count');
is($net->state_count, 6, 'State count');

# clone net
ok(my $net1 = $net->clone, 'Clone network');

# Unify net
ok(my $net2 = $net->unify(Lingua::Foma->new("{try}:{climb}")), 'Unknown method');

is($net->arc_count, 12, 'Arc count (net)');
is($net->state_count, 13, 'State count (net)');
is($net2->arc_count, 12, 'Arc count (net2)');
is($net2->state_count, 13, 'State count (net2)');
is($net1->arc_count, 5, 'Arc count (net1)');
is($net1->state_count, 6, 'State count (net1)');

# Check unification
is($net->up('check')->next, 'jump', 'Apply up (net)');
is($net->up('climb')->next, 'try', 'Apply up (net)');
is($net->down('jump')->next, 'check', 'Apply down (net)');
is($net->down('try')->next, 'climb', 'Apply down (net)');

# Unify with regex instead of fsm
isnt($net1->up('climb')->next, 'try', 'Apply up (net1) fail');
isnt($net1->down('try')->next, 'climb', 'Apply down (net1) fail');
ok($net1->unify("{try}:{climb}"), 'Unify with regex');
is($net1->up('climb')->next, 'try', 'Apply up (net1)');
is($net1->down('try')->next, 'climb', 'Apply down (net1)');

my $sing_dream = Lingua::Foma->new("{sing}:{dream}");

# Unify with multiples
ok($net1->unify("{track}:{paint}", $sing_dream, "{talk}:{lick}"));

is($net1->up('climb')->next, 'try', 'Apply up (net1)');
is($net1->down('try')->next, 'climb', 'Apply down (net1)');
isnt($net1->up('jump')->next, 'check', 'Apply up (net1)');
isnt($net1->down('check')->next, 'jump', 'Apply down (net1)');
is($net1->down('track')->next, 'paint', 'Apply down (net1)');
is($net1->up('paint')->next, 'track', 'Apply up (net1)');
is($net1->down('sing')->next, 'dream', 'Apply down (net1)');
is($net1->up('dream')->next, 'sing', 'Apply up (net1)');
is($net1->down('talk')->next, 'lick', 'Apply down (net1)');
is($net1->up('lick')->next, 'talk', 'Apply up (net1)');
is($net1->arc_count, 32, 'Arc count');
is($net1->state_count, 33, 'State count');
is($net1->final_count, 5, 'Final count');

is($sing_dream->down('sing')->next, 'dream', 'Apply down (sing_dream)');
is($sing_dream->up('dream')->next, 'sing', 'Apply up (sing_dream)');
is($sing_dream->arc_count, 5, 'Arc count');
is($sing_dream->state_count, 6, 'State count');
is($sing_dream->final_count, 1, 'Final count');
ok($sing_dream->is_epsilon_free, 'Is not epsilon free');


# IO
my $tempfile = tmpnam();

ok(my $net_save = $net1->save($tempfile), 'Save');
is("$net1", "$net_save", 'Return net is the same as the invocant');

ok(my $new_net = Lingua::Foma->load($tempfile), 'Load temporary file');
is($new_net->arc_count, 32, 'Arc count');
is($new_net->state_count, 33, 'State count');
is($new_net->final_count, 5, 'Final count');

# concat
ok($new_net->concat("0:{ing}"), 'Concatenate');
is($new_net->down('sing')->next, 'dreaming', 'Apply down (concat)');
is($new_net->up('dreaming')->next, 'sing', 'Apply up (concat)');



done_testing;
__END__


# $net1->concat("");

#isnt($net->up('checking')->next, 'jumping', 'Apply down');
#isnt($net->down('jumping')->next, 'checking', 'Apply up');


# $net->unify("{try}:{climb}");
# $net->unify($net2);



done_testing;
__END__
