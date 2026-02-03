use anyhow::Result;
use flutter_rust_bridge::frb;
use reqwest::Client;
use serde::{Deserialize, Serialize};

use super::streaming::{StreamingClient, StreamEvent};

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
    streaming_client: StreamingClient,
}

impl MisskeyRustClient {
    #[frb(sync)]
    pub fn new(host: String, token: String) -> MisskeyRustClient {
        let client = Client::builder()
            .user_agent("CyaniTalk/1.0 (Rust)")
            .danger_accept_invalid_certs(true) // Matching Dart's badCertificateCallback
            .build()
            .unwrap_or_default();

        MisskeyRustClient { 
            host, 
            token, 
            client,
            streaming_client: StreamingClient::new(),
        }
    }

    pub async fn i(&self) -> Result<String> {
        let url = format!("https://{}/api/i", self.host);
        let body = serde_json::json!({ "i": self.token });

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;
        
        let text = response.text().await?;
        Ok(text)
    }

    pub async fn get_timeline(
        &self,
        timeline_type: String,
        limit: u32,
        until_id: Option<String>,
    ) -> Result<String> {
        let endpoint = match timeline_type.as_str() {
            "Home" => "/api/notes/timeline",
            "Local" => "/api/notes/local-timeline",
            "Social" => "/api/notes/hybrid-timeline",
            "Global" => "/api/notes/global-timeline",
            _ => "/api/notes/timeline",
        };

        let url = format!("https://{}{}", self.host, endpoint);
        let mut body = serde_json::json!({
            "i": self.token,
            "limit": limit,
        });

        if let Some(id) = until_id {
            body.as_object_mut().unwrap().insert("untilId".to_string(), serde_json::Value::String(id));
        }

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        let text = response.text().await?;
        Ok(text)
    }

    pub async fn create_note(
        &self,
        text: Option<String>,
        reply_id: Option<String>,
        renote_id: Option<String>,
        visibility: Option<String>,
    ) -> Result<String> {
        let url = format!("https://{}/api/notes/create", self.host);
        let mut body = serde_json::json!({ "i": self.token });
        
        let obj = body.as_object_mut().unwrap();
        if let Some(t) = text { obj.insert("text".to_string(), serde_json::Value::String(t)); }
        if let Some(r) = reply_id { obj.insert("replyId".to_string(), serde_json::Value::String(r)); }
        if let Some(rn) = renote_id { obj.insert("renoteId".to_string(), serde_json::Value::String(rn)); }
        if let Some(v) = visibility { obj.insert("visibility".to_string(), serde_json::Value::String(v)); }

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        let text = response.text().await?;
        Ok(text)
    }

    pub async fn create_reaction(&self, note_id: String, reaction: String) -> Result<()> {
        let url = format!("https://{}/api/notes/reactions/create", self.host);
        let body = serde_json::json!({
            "i": self.token,
            "noteId": note_id,
            "reaction": reaction,
        });

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        if response.status().is_success() {
            Ok(())
        } else {
            Err(anyhow::anyhow!("Failed to create reaction: {}", response.status()))
        }
    }

    pub async fn connect_streaming(&self) -> Result<()> {
        self.streaming_client.connect(self.host.clone(), self.token.clone()).await
    }

    pub async fn disconnect_streaming(&self) -> Result<()> {
        self.streaming_client.disconnect().await
    }

    pub async fn send_streaming_message(&self, message: String) -> Result<()> {
        self.streaming_client.send_message(message).await
    }

    pub async fn subscribe_to_timeline(&self, timeline_type: String) -> Result<()> {
        let channel_name = match timeline_type.as_str() {
            "Home" => "homeTimeline",
            "Local" => "localTimeline", 
            "Social" => "hybridTimeline",
            "Global" => "globalTimeline",
            _ => "main",
        };
        
        let channel_id = format!("timeline-{}", channel_name);
        self.streaming_client.subscribe_to_channel(channel_name.to_string(), channel_id).await
    }

    pub async fn subscribe_to_main(&self) -> Result<()> {
        let channel_id = format!("main-channel-{}", chrono::offset::Utc::now().timestamp_millis());
        self.streaming_client.subscribe_to_channel("main".to_string(), channel_id).await
    }
    
    #[frb(sync)]
    pub fn poll_streaming_event(&self) -> Option<StreamEvent> {
        self.streaming_client.poll_event()
    }

    #[frb(sync)]
    pub fn is_streaming_connected(&self) -> bool {
        self.streaming_client.is_currently_connected()
    }

    pub async fn get_online_users_count(&self) -> Result<i32> {
        let url = format!("https://{}/api/get-online-users-count", self.host);
        let body = serde_json::json!({ "i": self.token });

        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await?;
        
        let text = response.text().await?;
        let json: serde_json::Value = serde_json::from_str(&text)?;
        
        // Extract the count from the response - Misskey API typically returns {"count": number}
        let count = json.get("count")
            .and_then(|v| v.as_i64())
            .unwrap_or(0) as i32;
        
        Ok(count)
    }
}

// Add a simple function to get the current timestamp for channel IDs
// We need to add chrono as a dependency for this
#[allow(unused_imports)]
use chrono::Datelike;

impl MisskeyRustClient {
    fn generate_channel_id(&self, prefix: &str) -> String {
        format!("{}-{}", prefix, chrono::offset::Utc::now().timestamp_millis())
    }
}
