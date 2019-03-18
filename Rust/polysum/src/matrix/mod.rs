use rug::{Rational};

mod prepare;
pub use prepare::*;

#[derive(Debug)]
pub struct AugmentedMatrix(Vec<Vec<Rational>>, Vec<Rational>, usize);

impl AugmentedMatrix {
  pub fn new(n: usize) -> Self {
    AugmentedMatrix(
      Vec::with_capacity(n+1),
      Vec::with_capacity(n+1),
      n
    )
  }

  pub fn n(&self) -> usize {
    self.2
  }

  #[allow(unused)]
  pub fn dimensions(&self) -> usize {
    self.2 + 1
  }

  pub fn n_is_even(&self) -> bool {
    self.n() % 2 == 0
  }

  pub fn coeffs_on_line(&self, i: usize) -> usize {
    self.0[i].len()
  }

  pub fn lines(&self) -> usize {
    self.0.len()
  }

  pub fn get_aug(&self, i: usize) -> &Rational {
    &self.1[i]
  }

  pub fn subtract_aug(&mut self, i: usize, value: &Rational) {
    self.1[i] -= value;
  }


  pub fn get_coeff(&self, i: usize, j: usize) -> &Rational {
    &self.0[i][j]
  }

  pub fn get_coeff_from_end(&self, i: usize, j: usize) -> &Rational {
    let c = self.coeffs_on_line(i);
    &self.0[i][c - 1 - j]
  }

  pub fn push_coeff(&mut self, i: usize, value: Rational) {
    self.0[i].push(value);
  }

  pub fn pop_coeff(&mut self, i: usize) -> Rational {
    self.0[i].pop().expect("oh no!! An empty pop from the AugmentedMatrix...")
  }

  pub fn alloc_coeffs(&mut self, size: usize) {
    self.0.push(Vec::with_capacity(size))
  }

  pub fn push_coeffs(&mut self, line: Vec<Rational>) {
    self.0.push(line)
  }

  pub fn push_aug(&mut self, value: Rational) {
    self.1.push(value)
  }
}

