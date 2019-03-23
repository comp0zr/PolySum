#include <iostream>
#include <vector>
#include <gmpxx.h>

namespace polysum {
  typedef std::vector<mpq_class> mpq_row;
  typedef std::vector<mpq_row> mpq_matrix;

  mpq_matrix make_matrix(size_t n) {
    mpq_matrix A(n+1, mpq_row(n+2, 0));
    A[0] = mpq_row(n+2, 1);

    for (size_t i = 1; i < n+1; i++) {
      for (size_t j = i; j < n+1; j++) {
        A[i][j] += A[i-1][j];
        A[i][j] *= (j - i + 2);
      }
      A[i][n+1] = A[i][n-1];
    }
    A[n][n+1] = A[n-1][n+1];
    return A;
  }

  void reduced_row_echelon(mpq_matrix& A) {
    size_t n = A.size() - 1;
    for (size_t i = n; i > 0; i--) {
      A[i][n+1] /= A[i][i];
      A[i][i] = 0;
      for (size_t j = i-1; j > 0; j--) {
        auto p = A[j][i];
        A[j][i] = 0;
        A[j][n+1] -= A[i][n+1] * p;
      }
    }
  }
}

void print_term(mpq_class& coeff, size_t i) {
  if (i != 0) std::cout << " + ";
  std::cout << coeff << "x";
  if (i != 0) std::cout << "^" << i+1;
}

int main(int argc, char* argv[]) {
  size_t n;
  if (argc == 2) {
    n = std::stoll(argv[1]);
  } else {
    std::cin >> n;
  }

  auto A = polysum::make_matrix(n);
  polysum::reduced_row_echelon(A);

  for (size_t i = 0; i <= n; i++) {
    print_term(A[i][n+1], i);
  }
  std::cout << "\n";
  return 0;
}
