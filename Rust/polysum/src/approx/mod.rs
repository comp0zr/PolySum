use crate::matrix::*;
use crate::polynomials::*;
use rug::{Rational};
use std::string::ToString;

pub fn sum(p: &Polynomial) -> Polynomial {
  let mut result = Polynomial::new(p.variable(), vec![]);
  for exp in 0..p.degree() {
    if p.constant(exp) != &0 {
      let mut approx = from_exponent(p.variable(), exp+1);
      approx *= p.constant(exp);
      result += approx;
    }
  }
  result
}

pub fn from_exponent<S: ToString>(var: S, n: usize) -> Polynomial {
  let zero = Rational::from((0, 1));
  let mut coeffs = vec![zero; n+1];
  for (i, coeff) in sum_coefficients(n) {
    coeffs[i-1] = coeff;
  }

  Polynomial::new(var.to_string(), coeffs)
}


pub fn sum_coefficients(n: usize) -> Vec<(usize, Rational)> {
  let mut matrix = AugmentedMatrix::new(n);
  matrix.prepare();
  matrix.get_coefficients_mut()
}

