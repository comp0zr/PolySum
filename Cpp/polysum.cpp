#include "polysum.h"
#include <iostream>
#include <sstream>

namespace polysum {
  typedef std::vector<mpq_class> mpq_row;
  typedef std::vector<mpq_class> mpq_column;
  typedef std::vector<mpq_row>   mpq_matrix;

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
    for (size_t i = n; i+1 > 0; i--) {
      A[i][n+1] /= A[i][i];
      A[i][i] = 1;
      for (size_t j = i-1; j+1 > 0; j--) {
        auto p = A[j][i];
        A[j][i] = 0;
        A[j][n+1] -= A[i][n+1] * p;
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
      auto r = polysum(v, i+1);
      result += polysum(v, i+1) * p.coefficient(i);
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
