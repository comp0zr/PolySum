#include <stdio.h>
#include <stdlib.h>
#include "polysum_c.h"

void print_poly(size_t n, mpq_t* poly) {
  for (int i = 0; i < n+1; i++) {
    gmp_printf("  poly[%d] =  %Qd\n", i, poly[i]);
  }
}

void print_poly_double(size_t n, double* poly) {
  for (int i = 0; i < n+1; i++) {
    printf("  poly[%d] =  %f\n", i, poly[i]);
  }
}


void test(size_t n) {
  mpq_t* poly = calloc(n+1, sizeof(mpq_t));
  polysum_from_exponent(n, poly);
  print_poly(n, poly);
}

void test_double(size_t n) {
  double* poly = calloc(n+1, sizeof(double));
  polysum_from_exponent_double(n, poly);
  print_poly_double(n, poly);
}


int main(int argc, char** argv) {
  size_t n = 0;

  if (argc <= 1) {
    scanf("%d", &n);
  } else {
    sscanf(argv[1], "%d", &n);
  }

  printf("polysum_from_exponent:\n");
  test(n);

  printf("\npolysum_from_exponent_double:\n");
  test_double(n);

  printf("\npolysum_with:\n");
  polysum_with(n, &print_poly);

  printf("\npolysum_with_double:\n");
  polysum_with_double(n, &print_poly_double);
  return 0;
}
