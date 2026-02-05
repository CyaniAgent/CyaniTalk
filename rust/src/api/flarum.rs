use anyhow::Result;
use flutter_rust_bridge::frb;
use reqwest::{Client, header};

#[frb(opaque)]
pub struct FlarumRustClient {
    base_url: String,
    token: Option<String>,
    user_id: Option<String>,
    client: Client,
}

impl FlarumRustClient {
    #[frb(sync)]
    pub fn new(base_url: String) -> FlarumRustClient {
        let mut headers = header::HeaderMap::new();
        headers.insert("Accept", header::HeaderValue::from_static("application/vnd.api+json"));
        headers.insert("Content-Type", header::HeaderValue::from_static("application/vnd.api+json"));

        let client = Client::builder()
            .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 CyaniTalk/1.0")
            .default_headers(headers)
            .cookie_store(true) // Enable cookie support
            .danger_accept_invalid_certs(true)
            .build()
            .unwrap_or_default();

        FlarumRustClient {
            base_url,
            token: None,
            user_id: None,
            client,
        }
    }

    pub fn set_token(&mut self, token: String, user_id: Option<String>) {
        self.token = Some(token);
        self.user_id = user_id;
    }

    pub fn clear_token(&mut self) {
        self.token = None;
        self.user_id = None;
    }

    pub async fn get(&self, path: String) -> Result<String> {
        let url = format!("{}{}", self.base_url, path);
        let mut request = self.client.get(&url);

        if let Some(token) = &self.token {
            let mut auth_val = format!("Token {}", token);
            if let Some(uid) = &self.user_id {
                auth_val = format!("{}; userId={}", auth_val, uid);
            }
            request = request.header("Authorization", auth_val);
        }

        let response = request.send().await?;
        let text = response.text().await?;
        Ok(text)
    }

    pub async fn post(&self, path: String, body_json: String) -> Result<String> {
        let url = format!("{}{}", self.base_url, path);
        let mut request = self.client.post(&url);

        if let Some(token) = &self.token {
            let mut auth_val = format!("Token {}", token);
            if let Some(uid) = &self.user_id {
                auth_val = format!("{}; userId={}", auth_val, uid);
            }
            request = request.header("Authorization", auth_val);
        }

        let response = request.body(body_json).send().await?;
        let text = response.text().await?;
        Ok(text)
    }
}
