use polysum::approx;
use gmp_mpfr_sys::gmp::mpq_t;
use rug::Rational;
use std::os::raw::c_double;
use std::ptr;

#[no_mangle]
pub unsafe extern "C" fn polysum_sum_coefficients(n: usize, out: *mut mpq_t) {
  for i in 0..=(n as isize) {
    ptr::write(out.offset(i), Rational::from((0,1)).into_raw());
  }

  for (i, coeff) in approx::sum_coefficients(n) {
    ptr::write(out.offset((i-1) as isize), coeff.into_raw());
  }
}

#[no_mangle]
pub unsafe extern "C" fn polysum_sum_coefficients_double(n: usize, out: *mut c_double) {
  for i in 0..=(n as isize) {
    ptr::write(out.offset(i), 0 as c_double);
  }

  for (i, coeff) in approx::sum_coefficients(n) {
    ptr::write(out.offset((i-1)  as isize), coeff.to_f64() as c_double);
  }
}

#[no_mangle]
pub unsafe extern "C" fn polysum_with_coefficients(n: usize, f: extern fn(usize, *mut mpq_t)) {
  let mut coeffs = vec![Rational::from((0, 1)).into_raw(); n+1];

  for (i, coeff) in approx::sum_coefficients(n) {
    coeffs[i-1] = coeff.into_raw();
  }

  f(n, coeffs.as_mut_ptr());
}

#[no_mangle]
pub unsafe extern "C" fn polysum_with_coefficients_double(n: usize, f: extern fn(usize, *mut c_double)) {
  let mut coeffs = vec![0 as c_double; n+1];

  for (i, coeff) in approx::sum_coefficients(n) {
    coeffs[i-1] = coeff.to_f64() as c_double;
  }

  f(n, coeffs.as_mut_ptr());
}

