fn main() {
    // This tells the Rust compiler that 'frb_expand' is a valid custom configuration
    // to avoid the 'unexpected_cfgs' warning.
    println!("cargo:rustc-check-cfg=cfg(frb_expand)");
}
