#![feature(proc_macro_hygiene)]
#![feature(try_from)]
#![feature(futures_api)]

use polysum::polynomials::*;
use polysum::approx;
use std::env;

fn parse_and_sum(src: &str) {
  match src.parse::<Polynomial>() {
    Ok(p) => {
      println!("input: {}", p);
      println!("result: {}", approx::sum(&p));
    },

    Err(e) => {
      println!("{:?}", e);
    }
  }
}

const HELP: &str = "
  polysum (n | expr)

  finds the polynomial Q such that Q(x) = sum P(i) for i from 0 to x.

  if given an integer as argument, it will take P(x) = x^n, otherwise
  will try to parse the polynomial.

  ------------
    examples
  ------------

  $ polysum 1
  1/2x + 1/2x^2

  $ polysum 3
  1/4x^2 + 1/2x^3 + 1/4x^4

  $ polysum 2x^2 + 5x^9
  input: 2x^2 + 5x^9
  result: 1/3x + 1/4x^2 + 2/3x^3 + 5/2x^4 - 7/2x^6 + 15/4x^8 + 5/2x^9 + 1/2x^10

  $ polysum 8a^3 + 3a^20
  input: 8a^3 + 3a^20
  result: 174611/110a + 2a^2 + 219419/21a^3 + 2a^4 - 206169/10a^5 + 19380a^7 - 223193/21a^9 + 41990/11a^11 - 969a^13 + 1292/7a^15 - 57/2a^17 + 5a^19 + 3/2a^20 + 1/7a^21
";

fn main() {
  let args: Vec<_> = env::args().collect();

  if args.len() == 1 {
    println!("{}", HELP);

  } else if args.len() == 2 {
    match args[1].parse() {
      Ok(power) => {
        println!("{}", approx::from_exponent("x", power));
      }
      Err(_) => {
        parse_and_sum(&args[1]);
      }
    }

  } else {
    let src = args[1..].join(" ");
    parse_and_sum(&src);
  }
}
