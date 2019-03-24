#include <vector>
#include <gmpxx.h>
#include <cstdint>
#include <iostream>


namespace polysum {
  typedef std::vector<mpq_class> mpq_row;
  typedef std::vector<mpq_class> mpq_column;
  typedef std::vector<mpq_row>   mpq_matrix;

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

      size_t degree() const {
        return this->coefficients.size();
      }

      const std::string variable_name() const {
        return this->variable;
      }

      const mpq_class& coefficient(size_t i) const {
        return this->coefficients[i];
      }

      void pad_coefficients(size_t n) {
        if (n > this->degree()) {
          this->coefficients.resize(n);
        }
      }

      auto coeffs() {
        return CoefficientIterator(this->coefficients);
      }

      friend std::istream& operator>>(std::istream&, Polynomial&);
  };
  std::ostream& operator<<(std::ostream&, const Polynomial&);
  std::istream& operator>>(std::istream&, Polynomial&);

  mpq_matrix make_matrix(size_t);
  void reduced_row_echelon(mpq_matrix&);
  mpq_column sum_coefficients(size_t);
  Polynomial polysum(Polynomial&);
  Polynomial polysum(size_t);
  Polynomial polysum(std::string, size_t);
}

