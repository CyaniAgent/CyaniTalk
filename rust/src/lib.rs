mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
pub mod api;

// Import commonly used types for the bridge
pub use serde_json::Value;

// Re-export commonly used types for easier access
pub use api::streaming::{StreamingClient, StreamEvent};
