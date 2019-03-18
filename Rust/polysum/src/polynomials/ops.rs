use crate::polynomials::*;
use rug::Rational;
use std::cmp::min;
use std::convert::TryInto;
use std::ops::{
  Add, AddAssign,
  Sub, SubAssign,
  Mul, MulAssign,
  Div, DivAssign,
  Neg
};

impl Add for Polynomial {
  type Output = Polynomial;

  fn add(self, other: Polynomial) -> Polynomial {
    let mut new = self.clone();
    new += other;
    new
  }
}

impl Sub for Polynomial {
  type Output = Polynomial;

  fn sub(self, other: Polynomial) -> Polynomial {
    let mut new = self.clone();
    new -= other;
    new
  }
}

impl<T: TryInto<Rational>> Mul<T> for Polynomial {
  type Output = Polynomial;

  fn mul(self, other: T) -> Polynomial {
    let mut new = self.clone();
    new *= other;
    new
  }
}

impl<T: TryInto<Rational>> Div<T> for Polynomial {
  type Output = Polynomial;

  fn div(self, other: T) -> Polynomial {
    let mut new = self.clone();
    new /= other;
    new
  }
}

impl AddAssign for Polynomial {
  fn add_assign(&mut self, other: Polynomial) {
    self.pad_terms(other.len());
    for exp in 0..min(self.len(), other.len()) {
      *self.constant_mut(exp) += other.constant(exp);
    }
  }
}

impl SubAssign for Polynomial {
  fn sub_assign(&mut self, other: Polynomial) {
    self.pad_terms(other.len());
    for exp in 0..min(self.len(), other.len()) {
      *self.constant_mut(exp) -= other.constant(exp);
    }
  }
}

impl<T: TryInto<Rational>> MulAssign<T> for Polynomial {
  fn mul_assign(&mut self, other: T) {
    if let Ok(n) = other.try_into() {
      for exp in 0..self.len() {
        *self.constant_mut(exp) *= &n;
      }
    }
  }
}

impl<T: TryInto<Rational>> DivAssign<T> for Polynomial {
  fn div_assign(&mut self, other: T) {
    if let Ok(n) = other.try_into() {
      for exp in 0..self.len() {
        *self.constant_mut(exp) /= &n;
      }
    }
  }
}

impl Neg for Polynomial {
  type Output = Polynomial;

  fn neg(self) -> Polynomial {
    let mut new = self.clone();
    new.negate();
    new
  }
}

