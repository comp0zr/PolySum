#include "polysum.h"
#include "equation_iterator.h"
#include "linear_system.h"
#include "polynomial.h"
#include <iostream>
#include <sstream>

namespace polysum {
  using std::move;

  mpq_class next_column(mpq_class x, size_t i, size_t j, size_t step) {
     mpq_class result = x;
     for (size_t k = 0; k < step; k++) {
       result *= (j + 1 - k);
       result /= (j + 1 - k) - i;
     }
     return result;
  }

  size_t initial_row(size_t n) {
    return (n % 2 == 0) ? 0 : 1;
  }

  Diagonal diagonal(size_t n) {
    if (n > 1) {
      size_t start = initial_row(n);
      Diagonal diag{Pivot(start)};

      for (size_t i = start; i < n-2; i+=2) {
        diag.push_back(diag.back().next_next());
      }
      return diag;

    } else {
      return Diagonal{};
    }
  }

  size_t column_step(size_t current, size_t n) {
    return (current >= n - 2) ? 1 : 2;
  }

  LinearSystem make_system(size_t n) {
    auto diag = diagonal(n);
    LinearSystem system(n/2);

    for (auto pivot : diag) {
      size_t row  = pivot.row;
      size_t step = column_step(row, n);
      mpq_row coeffs { move(pivot.value) };

      for (size_t column = row+step; column < n+1; column+=step) {
        auto next = next_column(coeffs.back(), row, column, step);
        coeffs.push_back(move(next));
        step = column_step(column, n);
      }
      auto independent = coeffs.end()[-2];
      system[row/2] = Equation(row, coeffs, independent);
    }
    system.push_back(Equation(n-1,  {1, 0}, mpq_class(1)/2));
    system.push_back(Equation(n,       {1}, mpq_class(1)/(n+1)));
    return system;
  }

  void reduced_row_echelon(LinearSystem& system) {
    for (auto equation_base : system.bottom_to_top()) {

      auto index = equation_base->index();
      auto pivot = equation_base->pop_rightmost_coefficient();
      auto indep = equation_base->independent /= pivot;

      for (auto equation_sub : system.to_top(index-1)) {
        auto c = equation_sub->pop_rightmost_coefficient();
        equation_sub->independent -= c * indep;
      }
    }
  }

  mpq_column sum_coefficients(size_t n) {
    auto S = make_system(n);
    reduced_row_echelon(S);
    mpq_column result(n + 1, 0);

    for (auto equation : S) {
      result[equation->row] = equation->independent;
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
