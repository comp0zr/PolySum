pub fn document(body: &str) -> String {
  let mut result = String::new();
  result.push_str("\\documentclass[preview, border={2em, 1in}]{standalone}\n");
  result.push_str("\\usepackage{breqn}\n");
  result.push_str("\\usepackage[landscape]{geometry}\n");
  result.push_str("\\begin{document}\n");
  result.push_str("\\begin{dmath*}[spread=12pt]\n");
  result.push_str(body);
  result.push_str("\n\\end{dmath*}\n");
  result.push_str("\\end{document}\n");
  result
}
