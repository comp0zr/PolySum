#include "gmp.h"
#include "polysum.h"
#include "polynomial.h"
#include <cmath>

namespace polysum {
//
// Constructors
//
  Polynomial::Polynomial(std::string variable) :
    variable(variable)
    {}

  Polynomial::Polynomial(std::string variable, size_t n) :
    coefficients(mpq_column(n, 0)),
    variable(variable)
    {}

  Polynomial::Polynomial(std::string variable, mpq_column cs) :
    coefficients(cs),
    variable(variable)
    {}

  Polynomial::Polynomial(const Polynomial& base) :
    variable(base.variable_name())
  {
    *this += base;
  }

//
// Data
//

  size_t Polynomial::degree() const {
    return coefficients.size();
  }

  const std::string Polynomial::variable_name() const {
    return variable;
  }

  const mpq_class& Polynomial::coefficient(size_t i) const {
    return coefficients[i];
  }

  void Polynomial::pad_coefficients(size_t n) {
    if (n > degree()) {
      coefficients.resize(n);
    }
  }

  auto Polynomial::coeffs() {
    return CoefficientIterator(this->coefficients);
  }

//
// Call Operator Overloading
//

#define POLYSUM_SPECIALIZE_CALL(T, MOD)                      \
  template <>                                                \
  mpq_class Polynomial::operator()(const T MOD x) const {    \
    T p = x + 0;                                             \
                                                             \
    mpq_class result(0);                                     \
    for (size_t i = 0; i < degree(); i++) {                  \
      result += coefficient(i) * p;                          \
      p *= x;                                                \
    }                                                        \
    return result;                                           \
  }

#define POLYSUM_SPECIALIZE_CALL_REF(T)  POLYSUM_SPECIALIZE_CALL(T,&)
#define POLYSUM_SPECIALIZE_CALL_COPY(T) POLYSUM_SPECIALIZE_CALL(T, )

  POLYSUM_SPECIALIZE_CALL_COPY(int);
  POLYSUM_SPECIALIZE_CALL_COPY(long int);
  POLYSUM_SPECIALIZE_CALL_COPY(unsigned int);
  POLYSUM_SPECIALIZE_CALL_COPY(long unsigned int);
  POLYSUM_SPECIALIZE_CALL_COPY(double);

  POLYSUM_SPECIALIZE_CALL_REF(int);
  POLYSUM_SPECIALIZE_CALL_REF(long int);
  POLYSUM_SPECIALIZE_CALL_REF(unsigned int);
  POLYSUM_SPECIALIZE_CALL_REF(long unsigned int);
  POLYSUM_SPECIALIZE_CALL_REF(double);

  POLYSUM_SPECIALIZE_CALL_COPY(mpq_class);
  POLYSUM_SPECIALIZE_CALL_COPY(mpz_class);
  POLYSUM_SPECIALIZE_CALL_COPY(mpf_class);

  POLYSUM_SPECIALIZE_CALL_REF(mpq_class);
  POLYSUM_SPECIALIZE_CALL_REF(mpz_class);
  POLYSUM_SPECIALIZE_CALL_REF(mpf_class);

//
// Math Operator Overloading
//

  Polynomial Polynomial::operator-() const {
    Polynomial p(*this);
    for (auto c : p.coeffs()) {
      c = -c;
    }
    return p;
  }

  Polynomial& Polynomial::operator*=(const mpq_class& q) {
    for (size_t i = 0; i < degree(); i++) {
      this->coefficients[i] *= q;
    }
    return *this;
  }

  Polynomial& Polynomial::operator/=(const mpq_class& q) {
    for (size_t i = 0; i < degree(); i++) {
      this->coefficients[i] /= q;
    }
    return *this;
  }

  Polynomial& Polynomial::operator+=(const Polynomial& other) {
    if (this->variable_name() == other.variable_name()) {
      this->pad_coefficients(other.degree());

      auto min = std::min(degree(), other.degree());

      for (size_t i = 0; i < min; i++) {
        coefficients[i] += other.coefficient(i);
      }
    }
    return *this;
  }

  Polynomial& Polynomial::operator-=(const Polynomial& other) {
    auto p = -other;
    *this += p;
    return *this;
  }

  Polynomial Polynomial::operator+(const Polynomial& other) const {
    Polynomial p(*this);
    p += other;
    return p;
  }

  Polynomial Polynomial::operator-(const Polynomial& other) const {
    Polynomial p(*this);
    p -= other;
    return p;
  }

  Polynomial Polynomial::operator*(const mpq_class& other) const {
    Polynomial p(*this);
    p *= other;
    return p;
  }

  Polynomial Polynomial::operator/(const mpq_class& other) const {
    Polynomial p(*this);
    p /= other;
    return p;
  }

//
// Input/Output Operator Overloading
//

  std::istream& operator>>(std::istream& strm, Polynomial& p) {
    int sign = 1;
    auto first = true;

    while (strm.peek() != EOF)  {
      strm >> std::ws;
      if (strm.peek() == '-') {
        sign = -1;
        strm.get();

      } else if (strm.peek() == '+') {
        sign = 1;
        strm.get();

      } else if (!first) {
        break;
      }
      strm >> std::ws;

      std::string name;
      mpq_class coefficient;

      if (isdigit(strm.peek())) {
        strm >> coefficient;
      } else {
        coefficient = 1;
      }

      while (isalpha(strm.peek())) {
         name.push_back(strm.get());
      }
      if (name == "") {
        if (first &&
            coefficient.get_den() == 1 &&
            coefficient.get_num()  > 0 &&
            sign == 1) {

          size_t i = coefficient.get_num().get_ui();
          p.variable = "x";
          p.pad_coefficients(i);
          p.coefficients[i-1] = 1;
        }
        break;

      } else if (first) {
        p.variable = name;

      } else if (name != p.variable) {
        break;
      }

      strm >> std::ws;

      size_t i;
      if (strm.peek() == '^') {
        strm.get();
        strm >> i;
      } else {
        i = 1;
      }

      if (i < 1) {
        break;
      }

      p.pad_coefficients(i);
      p.coefficients[i-1] += sign * coefficient;
      first = false;
    }
    return strm;
  }

  std::ostream& operator<<(std::ostream &strm, const Polynomial &p) {
    auto n = p.degree() - 1;
    auto first = true;
    for (size_t i = 0; i <= n; i++) {
      auto c = p.coefficient(i);

      if (c != 0) {
        if (!first) {
          strm << ((c < 0) ? " - " : " + ");
        }
        if (c != 1) {
          if (!first) {
            mpq_class ac = abs(c);
            strm << ac;
          } else {
            strm << c;
          }
        }
        strm << p.variable_name();
        if (i != 0) {
          strm << "^" << i+1;
        }
        first = false;
      }
    }
    return strm;
  }
}
