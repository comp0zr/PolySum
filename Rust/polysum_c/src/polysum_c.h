#ifndef POLYSUM_C_H_GUARD
#define POLYSUM_C_H_GUARD
#include <gmp.h>

void polysum_from_exponent(size_t, mpq_t*);
void polysum_from_exponent_double(size_t, double*);
void polysum_with(size_t, void(*function)(size_t, mpq_t*));
void polysum_with_double(size_t, void(*function)(size_t, double*));

#endif
