#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>
#include <stdlib.h>
#include "fomalib.h"
#include "ppport.h"


struct apply_iterator {
  struct apply_handle * handle;
  SV * fsm;
  char * word;
  int action;
};


typedef struct apply_iterator * Lingua__Foma__Iterator;
typedef struct fsm * Lingua__Foma;


#define _act_apply_up            0
#define _act_apply_down          1
#define _act_apply_upper_words   2
#define _act_apply_lower_words   3
#define _act_apply_words         4


#define RETURN_IV(var) XSRETURN_IV(this->var)


#define RETURN_TERNARY(var) \
if (this->var == 0) { XSRETURN_NO; } else if (this->var == 1) { XSRETURN_YES; }; \
XSRETURN_UNDEF


#define INIT_ITERATOR_HANDLE(HANDLEVAR)\
if ((HANDLEVAR = apply_init(this)) == NULL) { \
  if (PL_dowarn) \
    warn("Unable to initialize apply iterator"); \
  XSRETURN_UNDEF; \
}


#define WANTARRAY bool wantarray = (GIMME_V == G_ARRAY) ? 1 : 0


#define NEW_ITERATOR(WORDVAR,ACTIONVAR) \
struct apply_iterator * iterator;\
Newx(iterator, 1, struct apply_iterator);\
if (iterator == NULL)\
  XSRETURN_UNDEF;\
iterator->action = ACTIONVAR;\
iterator->word   = WORDVAR;\
if ((iterator->handle = apply_init(this)) == NULL) {\
  if (PL_dowarn)\
    warn("Unable to initialize apply iterator");\
  safefree(iterator);\
  XSRETURN_UNDEF;\
};\
SvREFCNT_inc(iterator->fsm = (SV*)SvRV(ST(0)));\
SV * piterator = newSViv(PTR2IV(iterator));\
sv_2mortal(piterator);\
piterator = newRV(piterator);\
sv_bless(piterator, gv_stashpv("Lingua::Foma::Iterator", 0));\
mPUSHs(piterator);\
SvREADONLY_on(piterator)


#define FORCE_WORD \
if (strlen(word) == 0) { \
  if (PL_dowarn)\
    warn("Please define a word");\
  XSRETURN_UNDEF;\
}


#define CHECK_INVOCANT(CLASSVAR) \
if (!sv_derived_from(this, CLASSVAR)) {\
  if (PL_dowarn)\
    warn("Method call from %s", CLASSVAR);\
  XSRETURN_UNDEF;\
}


#define CHECK_REGEX \
if (strlen(regex) == 0) {\
  if (PL_dowarn)\
    warn("Please pass a regular expression");\
  XSRETURN_UNDEF;\
}


#define EXPECT_FSMS \
if (items == 1) {\
  if (PL_dowarn)\
    warn("Please pass a regular expression or a Lingua::Foma object");\
  XSRETURN_UNDEF;\
}


#define GET_FSM_ITEM \
Lingua__Foma with_obj;\
IV tmp;\
if (!sv_derived_from(ST(i), "Lingua::Foma")) {\
  char * regex = (char *)SvPV_nolen(ST(i));\
  if (strlen(regex) == 0) {\
    if (PL_dowarn)\
      warn("Please pass a regular expression or a Lingua::Foma object");\
    XSRETURN_UNDEF;\
  };\
  with_obj = fsm_parse_regex(regex);\
  CHECK_REGEX;\
}\
else {\
  tmp = SvIV((SV*)SvRV(ST(i)));\
  with_obj = fsm_copy(INT2PTR(Lingua__Foma,tmp));\
}


#define RETURN_FINAL(NAMEVAR) \
if (this_p != NULL) {\
  SvIV_set(this_r, PTR2IV(this_p));\
  ST(0) = this;\
  SvREFCNT_inc(ST(0));\
  RETVAL = ST(0);\
}\
else {\
  if (PL_dowarn)\
    warn("Unable to %s automata", NAMEVAR);\
  XSRETURN_UNDEF;\
}


MODULE = Lingua::Foma      PACKAGE = Lingua::Foma

# Constructor: new
Lingua::Foma
new(char * package, char * regex)
  CODE:
    (void)package;
    CHECK_REGEX;
    RETVAL = fsm_parse_regex(regex);
    if (RETVAL == NULL) {
      if (PL_dowarn) {
 	warn("Error building network based on /%s/", regex);
      };
      XSRETURN_UNDEF;
    };
  OUTPUT:
    RETVAL


# Destructor
void
DESTROY(Lingua::Foma this)
  CODE:
    fsm_destroy(this);


# IOMethod: load
Lingua::Foma
load(char * package, char * file)
  INIT:
    Lingua__Foma new;
  CODE:
    (void)package;
    if (strlen(file) == 0) {
      if (PL_dowarn) {
 	warn("Please define a file");
      };
      XSRETURN_UNDEF;
    };

    new = fsm_read_binary_file(file);

    if (new == NULL) {
      if (PL_dowarn) {
 	warn("Error loading file '%s'", file);
      };
      XSRETURN_UNDEF;
    };
    RETVAL = new;
  OUTPUT:
    RETVAL


# IOMethod: save
SV *
save(SV * this, char * file)
  CODE:
    CHECK_INVOCANT("Lingua::Foma");
    if (strlen(file) == 0) {
      if (PL_dowarn)
 	warn("Please define a file");
      XSRETURN_UNDEF;
    };

    IV this_iv = SvIV((SV*)SvRV(this));
    Lingua__Foma this_obj = INT2PTR(Lingua__Foma,this_iv);

    if ((fsm_write_binary_file(this_obj, file)) != 0) {
      if (PL_dowarn)
 	warn("Error saving to file '%s'", file);
      XSRETURN_UNDEF;
    };

    ST(0) = this;
    SvREFCNT_inc(ST(0));
    RETVAL = ST(0);
  OUTPUT:
    RETVAL


# Attribute: arc_count
SV *
arc_count(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_IV(arccount);


# Attribute: final_count
SV *
final_count(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_IV(finalcount);


# Attribute: state_count
SV *
state_count(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_IV(statecount);


# Attribute: is_completed
SV *
is_completed(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_completed);


# Attribute: is_deterministic
SV *
is_deterministic(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_deterministic);


# Attribute: is_epsilon_free
SV *
is_epsilon_free(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_epsilon_free);


# Attribute: is_loop_free
SV *
is_loop_free(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_loop_free);


# Attribute: is_minimized
SV *
is_minimized(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_minimized);


# Attribute: is_pruned
SV *
is_pruned(Lingua::Foma this)
  PROTOTYPE: $
  CODE:
    RETURN_TERNARY(is_pruned);


# ClassVariable: lib_version
SV *
lib_version ()
  CODE:
    XSRETURN_PV(fsm_get_library_version_string());


# StringMethod: up
void
up(Lingua::Foma this, char * word)
  PROTOTYPE: $$
  PPCODE:
    FORCE_WORD;
    WANTARRAY;
    if (wantarray) {
      AV * resultArray =
	  (AV *)sv_2mortal((SV *)newAV());
      struct apply_handle *ah;
      INIT_ITERATOR_HANDLE(ah);
      char * result = apply_up(ah, word);
      while (result != NULL) {
        mXPUSHp(result, strlen(result));
        result = apply_up(ah, NULL);
      };
      apply_clear(ah);
      XSRETURN(1);
    };
    NEW_ITERATOR(word, _act_apply_up);


# StringMethod: down
void
down(Lingua::Foma this, char * word)
  PROTOTYPE: $$
  PPCODE:
    FORCE_WORD;
    WANTARRAY;
    if (wantarray) {
      AV * resultArray =
	  (AV *)sv_2mortal((SV *)newAV());
      struct apply_handle *ah;
      INIT_ITERATOR_HANDLE(ah);
      char * result = apply_down(ah, word);
      while (result != NULL) {
        mXPUSHp(result, strlen(result));
        result = apply_down(ah, NULL);
      };
      free(word);
      apply_clear(ah);
      XSRETURN(1);
    };
    NEW_ITERATOR(word, _act_apply_down);



# AutomatonMethod: clone
void
clone(Lingua::Foma this)
  PROTOTYPE: $
  PPCODE:
    SV * clone = newSViv(PTR2IV(fsm_copy(this)));
    sv_2mortal(clone);
    clone = newRV(clone);
    sv_bless(
      clone,
      gv_stashpv("Lingua::Foma", 0)
    );
    mPUSHs(clone);
    SvREADONLY_on(clone);


# AutomatonMethod: unify
SV *
unify(SV * this, ...)
  INIT:
    int i;
  CODE:
    CHECK_INVOCANT("Lingua::Foma");
    EXPECT_FSMS;

    SV * this_r = (SV*)SvRV(this);
    Lingua__Foma this_p = INT2PTR(Lingua__Foma,SvIV(this_r));

    // Iterate over all passed automata
    for (i = 1; i < items; i++) {
      GET_FSM_ITEM;
      this_p = fsm_union(this_p, with_obj);
    };
    RETURN_FINAL("unify");
  OUTPUT:
    RETVAL


# AutomatonMethod: concat
SV *
concat(SV * this, ...)
  INIT:
    int i;
  CODE:
    CHECK_INVOCANT("Lingua::Foma");
    EXPECT_FSMS;

    SV * this_r = (SV*)SvRV(this);
    Lingua__Foma this_p = INT2PTR(Lingua__Foma,SvIV(this_r));

    // Iterate over all passed automata
    for (i = 1; i < items; i++) {
      GET_FSM_ITEM;
      this_p = fsm_concat(this_p, with_obj);
    };
    RETURN_FINAL("concat");
  OUTPUT:
    RETVAL


MODULE = Lingua::Foma    PACKAGE = Lingua::Foma::Iterator    PREFIX = iter_

# Destructor
void
iter_DESTROY(SV * this)
  CODE:
    CHECK_INVOCANT("Lingua::Foma::Iterator");

    IV tmp = SvIV((SV*)SvRV(ST(0)));

    struct apply_iterator * iter =
	INT2PTR(Lingua__Foma__Iterator,tmp);

    SvREFCNT_dec(iter->fsm);
    apply_clear(iter->handle);
    free(iter);


# next
SV *
iter_next(Lingua::Foma::Iterator this)
  PROTOTYPE: $
  CODE:
    char * found;
    switch (this->action) {
      case _act_apply_up: {
	found = apply_up(this->handle, this->word);
	break;
      }
      case _act_apply_down: {
        found = apply_down(this->handle, this->word);
        break;
      }
      case _act_apply_upper_words: {
        found = apply_upper_words(this->handle);
        break;
      }
      case _act_apply_lower_words: {
        found = apply_lower_words(this->handle);
        break;
      }
      case _act_apply_words: {
        found = apply_words(this->handle);
        break;
      };
    };
    if (this->word != NULL) {
      this->word = NULL;
    };
    if (found == NULL) {
      XSRETURN_UNDEF;
    }
    else {
	RETVAL = newSVpv(found, strlen(found));
    };
  OUTPUT:
    RETVAL
