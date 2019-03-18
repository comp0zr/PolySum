use rug::{Rational};
use crate::matrix::*;

pub trait PolySumMatrix<T> {
  fn prepare(&mut self);
  fn get_coefficients_mut(&mut self) -> Vec<(usize, T)>;
  fn full_matrix(&self) -> Vec<Vec<T>>;
}

fn rat(u: usize) -> Rational {
  Rational::from((u,1))
}


fn ratio(n: usize, d: usize) -> Rational {
  Rational::from((n,d))
}


impl PolySumMatrix<Rational> for AugmentedMatrix {
  fn full_matrix(&self) -> Vec<Vec<Rational>> {
    let n = self.n();
    let zero = rat(0);
    let mut result = vec![vec![zero; n+2]; n+1];

    if n >= 2 {
      let start_line = if self.n_is_even() {0} else {1};

      for i in (start_line..=(n-2)).step_by(2) {
        for j in 0..self.coeffs_on_line(i/2) {
          result[i][j+i] = self.get_coeff(i/2, j).clone();
        }
        result[i][n+1] = self.get_aug(i/2).clone();
      }
    }
    result[n-1][n-1] = rat(1);
    result[n-1][n+1] = ratio(1,2);
    result[n][n]     = rat(1);
    result[n][n+1]   = ratio(1,n+1);
    result
  }

  fn prepare(&mut self) {
    let n = self.n();
    let next_line;

    if n >= 2 {
      if self.n_is_even() {
        let one = rat(1);
        self.push_coeffs(vec![one; n+1]);
        self.push_aug(rat(1));
        next_line = 2;

      } else {
        self.alloc_coeffs(n);
        for i in 2..=(n+1) {
          self.push_coeff(0, rat(i))
        }
        self.push_aug(rat(n));
        next_line = 3;
      }

      for i in (next_line..=(n-2)).step_by(2) {
        self.alloc_coeffs((n + 1) - i);
        for j in i..=n {
          let mut above = rat(((j + 2) - i) * ((j + 3) - i));
          above *= self.get_coeff((i/2)-1, j-i+2);
          self.push_coeff(i/2, above);
        }
        let aug = self.get_coeff_from_end(i/2, 1).clone();
        self.push_aug(aug);
      }
    }
  }

  fn get_coefficients_mut(&mut self) -> Vec<(usize, Rational)> {
    let mut result = Vec::with_capacity(self.n()+1);
    let start_line = if self.n_is_even() {0} else {1};
    let a1 = ratio(1, self.n()+1);
    let a2 = ratio(1, 2);
    for i in 0..self.lines() {
      let c1 = self.pop_coeff(i);
      let c2 = self.pop_coeff(i);
      self.subtract_aug(i, &(&a1 * c1));
      self.subtract_aug(i, &(&a2 * c2));
    }
    result.push((self.n()+1, a1));
    result.push((self.n(),   a2));

    let lines = self.lines();
    for i in (1..lines).rev() {
      let ci = self.pop_coeff(i);
      let ai = self.get_aug(i) / ci;

      for j in (0..i).rev() {
        let cj = self.pop_coeff(j);
        self.pop_coeff(j);
        self.subtract_aug(j, &(cj * &ai));
      }
      result.push((2*i + start_line + 1, ai));
    }
    if self.n() >= 2 {
      let cf = self.pop_coeff(0);
      let af = self.get_aug(0) / cf;
      result.push((start_line+1, af));
    }
    result
  }
}
