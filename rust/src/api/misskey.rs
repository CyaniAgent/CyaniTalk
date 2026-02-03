use anyhow::Result;
use flutter_rust_bridge::frb;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Serialize, Deserialize, Debug)]
pub struct MisskeyUser {
    pub id: String,
    pub name: Option<String>,
    pub username: String,
    // Add more fields as needed, using Option for nullable fields
}

#[frb(opaque)]
pub struct MisskeyRustClient {
    host: String,
    token: String,
    client: Client,
}

impl MisskeyRustClient {
    #[frb(sync)]
    pub fn new(host: String, token: String) -> MisskeyRustClient {
        let client = Client::builder()
            .user_agent("CyaniTalk/1.0 (Rust)")
            .danger_accept_invalid_certs(true) // Matching Dart's badCertificateCallback
            .build()
            .unwrap_or_default();

        MisskeyRustClient { host, token, client }
    }

    pub async fn i(&self) -> Result<String> {
        let url = format!("https://{}/api/i", self.host);
        let body = serde_json::json!({ "i": self.token });

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;
        
        // Returning JSON string for now to keep it flexible while porting
        let text = response.text().await?;
        Ok(text)
    }
}
