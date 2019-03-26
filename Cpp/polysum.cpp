#include "polysum.h"
#include <iostream>
#include <sstream>

namespace polysum {
  mpq_matrix make_matrix(size_t n) {
    mpq_matrix A(n+1, mpq_row(n+2, 0));

    size_t start;
    if (n >= 2) {
      if (n % 2 == 0) {
        A[0] = mpq_row(n+2, 1);
        start = 2;

      } else {
        for (size_t i = 1; i < n+1; i++) {
          A[1][i] = i + 1;
        }
        A[1][n+1] = n;
        start = 3;
      }
    }

    for (size_t i = start; i < n-1; i+=2) {
      size_t step = 2;
      for (size_t j = i; j < n+1; j+=step) {
        A[i][j] += A[i-2][j];
        A[i][j] *= (j - i + 2) * (j - (i - 1) + 2);
        if (j >= n - 2) {
          step = 1;
        }
      }
      A[i][n+1] = A[i][n-1];
    }

    A[n-1][n-1] = 1;
    A[n-1][n+1] = mpq_class(1) / 2;
    A[n][n]     = 1;
    A[n][n+1]   = mpq_class(1) / (n+1);
    return A;
  }

  void reduced_row_echelon(mpq_matrix& A) {
    size_t n = A.size() - 1;
    auto c1 = A[n][n+1];
    auto c2 = A[n-1][n+1];
    for (size_t j = n-2; j+2 >= 2; j-=2) {
      auto p1   = A[j][n];
      auto p2   = A[j][n-1];
      A[j][n]   = 0;
      A[j][n-1] = 0;
      A[j][n+1] -= c1 * p1;
      A[j][n+1] -= c2 * p2;
    }

    for (size_t i = n-2; i+2 >= 2; i-=2) {
      if (A[i][i] != 0) {
        A[i][n+1] /= A[i][i];
        auto c = A[i][n+1];
        for (size_t j = i-2; j+2 >= 2; j-=2) {
          auto p = A[j][i];
          A[j][i] = 0;
          A[j][n+1] -= c * p;
        }
      }
    }
  }

  mpq_column sum_coefficients(size_t n) {
    auto A = make_matrix(n);
    reduced_row_echelon(A);

    mpq_column result;
    for (auto row: A) {
      result.push_back(row[n+1]);
    }
    return result;
  }

  Polynomial polysum(Polynomial& p) {
    std::string v = p.variable_name();

    Polynomial result(v);
    for (size_t i = 0; i < p.degree(); i++) {
      if (p.coefficient(i) != 0) {
        result += polysum(v, i+1) * p.coefficient(i);
      }
    }
    return result;
  }

  Polynomial polysum(std::string variable_name, size_t n) {
    return Polynomial(variable_name, sum_coefficients(n));
  }

  Polynomial polysum(size_t n) {
    return polysum("x", n);
  }
}

void read_and_print_polysum(std::istream& strm, std::string arg) {
  polysum::Polynomial p("");
  strm >> p;
  auto ps = polysum::polysum(p);

  std::cout << "base polynomial: "  << p  << "\n";
  std::cout << "resulting polynomial: " << ps << "\n";

  if (arg != "") {
    std::stringstream args(arg);
    mpz_class z;
    args >> z;
    std::cout << "result: " << ps(z) << "\n";
  }
}

int main(int argc, char* argv[]) {
  if (argc == 2) {
    std::stringstream s(argv[1]);
    read_and_print_polysum(s, "");

  } else if (argc == 3) {
    std::stringstream s(argv[1]);
    read_and_print_polysum(s, argv[2]);

  } else {
    read_and_print_polysum(std::cin, "");
  }
  return 0;
}
