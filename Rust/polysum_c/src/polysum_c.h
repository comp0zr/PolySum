#ifndef POLYSUM_C_H_GUARD
#define POLYSUM_C_H_GUARD
#include <gmp.h>

void polysum_sum_coefficients(size_t, mpq_t*);
void polysum_sum_coefficients_double(size_t, double*);
void polysum_with_coefficients(size_t, void(*function)(size_t, mpq_t*));
void polysum_with_coefficients_double(size_t, void(*function)(size_t, double*));

#endif
