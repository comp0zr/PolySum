#include <stdio.h>
#include <stdlib.h>
#include "polysum_c.h"

void print_poly(size_t n, mpq_t* poly) {
  for (size_t i = 0; i < n+1; i++) {
    gmp_printf("  poly[%ld] =  %Qd\n", i, poly[i]);
  }
}

void print_poly_double(size_t n, double* poly) {
  for (size_t i = 0; i < n+1; i++) {
    printf("  poly[%ld] =  %f\n", i, poly[i]);
  }
}


void test(size_t n) {
  mpq_t* poly = calloc(n+1, sizeof(mpq_t));
  polysum_sum_coefficients(n, poly);
  print_poly(n, poly);
}

void test_double(size_t n) {
  double* poly = calloc(n+1, sizeof(double));
  polysum_sum_coefficients_double(n, poly);
  print_poly_double(n, poly);
}


int main(int argc, char** argv) {
  size_t n = 0;

  if (argc <= 1) {
    scanf("%ld", &n);
  } else {
    sscanf(argv[1], "%ld", &n);
  }

  printf("polysum_sum_coefficients:\n");
  test(n);

  printf("\npolysum_sum_coefficients_double:\n");
  test_double(n);

  printf("\npolysum_with_coefficients:\n");
  polysum_with_coefficients(n, &print_poly);

  printf("\npolysum_with_coefficients_double:\n");
  polysum_with_coefficients_double(n, &print_poly_double);
  return 0;
}
