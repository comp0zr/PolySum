#pragma once
#include "polysum.h"

namespace polysum {
  class Polynomial {
    private:
      std::string variable;
      mpq_column coefficients;

    public:
      Polynomial(std::string);
      Polynomial(std::string, size_t);
      Polynomial(std::string, mpq_column);
      Polynomial(const Polynomial&);

      template <typename T>
      mpq_class operator()(const T) const;

      Polynomial operator-() const;

      Polynomial& operator+=(const Polynomial&);
      Polynomial& operator-=(const Polynomial&);

      Polynomial& operator*=(const mpq_class&);
      Polynomial& operator/=(const mpq_class&);

      Polynomial operator+(const Polynomial&) const;
      Polynomial operator-(const Polynomial&) const;

      Polynomial operator*(const mpq_class&) const;
      Polynomial operator/(const mpq_class&) const;

      size_t degree() const;
      const std::string variable_name() const;
      const mpq_class& coefficient(size_t i) const;
      void pad_coefficients(size_t n);
      auto coeffs();

      friend std::istream& operator>>(std::istream&, Polynomial&);
  };
  std::ostream& operator<<(std::ostream&, const Polynomial&);
  std::istream& operator>>(std::istream&, Polynomial&);

  class CoefficientIterator {
    private:
      mpq_column& coefficients;
    public:
      CoefficientIterator(mpq_column& cs) : coefficients(cs) {};
      auto begin() {
        return this->coefficients.begin();
      }
      auto end() {
        return this->coefficients.begin();
      }
  };

}
