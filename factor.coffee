# factor a polynomial or integer

#include "stdafx.h"
#include "defs.h"

Eval_factor = ->
	push(cadr(p1));
	Eval();

	push(caddr(p1));
	Eval();

	p2 = pop();
	if (p2 == symbol(NIL))
		guess();
	else
		push(p2);

	factor();

	# more factoring?

	p1 = cdddr(p1);
	while (iscons(p1))
		push(car(p1));
		Eval();
		factor_again();
		p1 = cdr(p1);

factor_again = ->

	save();

	p2 = pop();
	p1 = pop();

	h = tos;

	if (car(p1) == symbol(MULTIPLY))
		p1 = cdr(p1);
		while (iscons(p1))
			push(car(p1));
			push(p2);
			factor_term();
			p1 = cdr(p1);
	else
		push(p1);
		push(p2);
		factor_term();

	n = tos - h;

	if (n > 1)
		multiply_all_noexpand(n);

	restore();

factor_term = ->
	save();
	factorpoly();
	p1 = pop();
	if (car(p1) == symbol(MULTIPLY))
		p1 = cdr(p1);
		while (iscons(p1))
			push(car(p1));
			p1 = cdr(p1);
	else
		push(p1);
	restore();

factor = ->
	save();
	p2 = pop();
	p1 = pop();
	if (isinteger(p1))
		push(p1);
		factor_number(); # see pollard.cpp
	else
		push(p1);
		push(p2);
		factorpoly();
	restore();

# for factoring small integers (2^32 or less)

factor_small_number = ->

	debugger
	save();

	n = pop_integer();

	if (n == 0x80000000)
		stop("number too big to factor");

	if (n < 0)
		n = -n;

	for i in [0...MAXPRIMETAB]

		d = primetab[i];

		if (d > n / d)
			break;

		expo = 0;

		while (n % d == 0)
			n /= d;
			expo++;

		if (expo)
			push_integer(d);
			push_integer(expo);

	if (n > 1)
		push_integer(n);
		push_integer(1);

	restore();

#if SELFTEST

s = [

	"factor(0)",
	"0",

	"factor(1)",
	"1",

	"factor(2)",
	"2",

	"factor(3)",
	"3",

	"factor(4)",
	"2^2",

	"factor(5)",
	"5",

	"factor(6)",
	"2*3",

	"factor(7)",
	"7",

	"factor(8)",
	"2^3",

	"factor(9)",
	"3^2",

	"factor(10)",
	"2*5",

	"factor(100!)",
	"2^97*3^48*5^24*7^16*11^9*13^7*17^5*19^5*23^4*29^3*31^3*37^2*41^2*43^2*47^2*53*59*61*67*71*73*79*83*89*97",

	"factor(2*(2^30-35))",
	"2*1073741789",

	# x is the 10,000th prime

	# Prime factors greater than x^2 are found using the Pollard rho method

	"a=104729",
	"",

	"factor(2*(a^2+6))",
	"2*10968163447",

	"factor((a^2+6)^2)",
	"10968163447*10968163447",	# FIXME should be 10968163447^2

	"factor((a^2+6)*(a^2+60))",
	"10968163501*10968163447",	# FIXME sort order

	"f=(x+1)(x+2)(y+3)(y+4)",
	"",

	"factor(f,x,y)",
	"(x+1)*(x+2)*(y+3)*(y+4)",

	"factor(f,y,x)",
	"(x+1)*(x+2)*(y+3)*(y+4)",

	"f=(x+1)(x+1)(y+2)(y+2)",
	"",

	"factor(f,x,y)",
	"(x+1)^2*(y+2)^2",

	"factor(f,y,x)",
	"(x+1)^2*(y+2)^2",
]

###
void
test_factor_number(void)
{
	test(__FILE__, s, sizeof s / sizeof (char *));
}

#endif
###