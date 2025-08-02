use napi::bindgen_prelude::*;

#[napi]
fn greet(name: String) -> String {
  format!("Hello, {} from Rust!", name)
}
