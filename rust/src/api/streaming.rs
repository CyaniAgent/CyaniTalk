use anyhow::Result;
use flutter_rust_bridge::frb;
use futures_channel::mpsc;
use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex as StdMutex};
use tokio::sync::Mutex;
use tokio_tungstenite::{connect_async, tungstenite::protocol::Message};
use tokio::time::{Duration, interval};
use tokio::sync::mpsc as tokio_mpsc;
use tokio::task;

#[derive(Serialize, Deserialize, Debug)]
pub struct StreamEvent {
    pub event_type: String,
    pub body: serde_json::Value,
    pub channel_id: String,
}

#[derive(Clone)]
pub struct StreamingClient {
    tx: Arc<Mutex<Option<mpsc::UnboundedSender<Message>>>>,
    event_tx: tokio_mpsc::UnboundedSender<StreamEvent>,
    // Use tokio::sync::mpsc for the event receiver to make it compatible with FRB
    poll_rx: Arc<StdMutex<Option<tokio_mpsc::UnboundedReceiver<StreamEvent>>>>,
    is_connected: Arc<Mutex<bool>>,
    connection_task_handle: Arc<Mutex<Option<task::JoinHandle<()>>>>,
}

impl StreamingClient {
    #[frb(sync)]
    pub fn new() -> Self {
        let (event_tx, poll_rx) = tokio_mpsc::unbounded_channel();
        StreamingClient {
            tx: Arc::new(Mutex::new(None)),
            event_tx,
            poll_rx: Arc::new(StdMutex::new(Some(poll_rx))),
            is_connected: Arc::new(Mutex::new(false)),
            connection_task_handle: Arc::new(Mutex::new(None)),
        }
    }

    pub async fn connect(&self, url: String, token: String) -> Result<()> {
        // Check if already connected
        if *self.is_connected.lock().await {
            return Ok(());
        }

        let ws_url = format!("wss://{}/streaming?i={}", url, token);

        let (ws_stream, _) = connect_async(ws_url).await?;
        let (mut ws_write, ws_read) = ws_stream.split();

        let (tx, mut rx) = mpsc::unbounded();
        {
            let mut self_tx = self.tx.lock().await;
            *self_tx = Some(tx);
        }

        // Update connection status
        {
            let mut connected = self.is_connected.lock().await;
            *connected = true;
        }

        // Clone event_tx for the read loop
        let event_tx_clone = self.event_tx.clone();
        let is_connected_clone = self.is_connected.clone();

        // Spawn the read task
        let read_handle = tokio::spawn(async move {
            let mut ws_read = ws_read;
            while let Some(msg) = ws_read.next().await {
                match msg {
                    Ok(message) => {
                        if let Message::Text(text) = message {
                            if let Ok(data) = serde_json::from_str::<serde_json::Value>(&text) {
                                let event_type = data.get("type").and_then(|v| v.as_str()).unwrap_or("");
                                
                                // Handle different message types
                                if event_type == "channel" {
                                    // Extract channel event data
                                    let body = data.get("body").unwrap_or(&serde_json::Value::Null).clone();
                                    let channel_id = body.get("id")
                                        .and_then(|v| v.as_str())
                                        .unwrap_or("")
                                        .to_string();
                                    let inner_event_type = body.get("type")
                                        .and_then(|v| v.as_str())
                                        .unwrap_or("")
                                        .to_string();
                                    
                                    if !inner_event_type.is_empty() {
                                        // Create a new event structure that includes both the inner type and original body
                                        let stream_event = StreamEvent {
                                            event_type: inner_event_type,
                                            body: body.get("body").unwrap_or(&serde_json::Value::Null).clone(),
                                            channel_id,
                                        };

                                        if event_tx_clone.send(stream_event).is_err() {
                                            break; // Event receiver dropped
                                        }
                                    }
                                } else {
                                    // Handle non-channel events
                                    let channel_id = data.get("id")
                                        .and_then(|v| v.as_str())
                                        .unwrap_or("")
                                        .to_string();

                                    let stream_event = StreamEvent {
                                        event_type: event_type.to_string(),
                                        body: data.clone(), // Send the full data for non-channel events
                                        channel_id,
                                    };

                                    if event_tx_clone.send(stream_event).is_err() {
                                        break; // Event receiver dropped
                                    }
                                }
                            }
                        } else if let Message::Close(_) = message {
                            // Connection closed by server
                            break;
                        }
                    }
                    Err(e) => {
                        eprintln!("WebSocket error: {}", e);
                        break;
                    }
                }
            }
            
            // Connection was lost, update status
            let mut connected = is_connected_clone.lock().await;
            *connected = false;
        });

        // Spawn the write task
        let ws_write_clone = ws_write;
        let write_handle = tokio::spawn(async move {
            let mut ws_write = ws_write_clone;
            while let Some(msg) = rx.next().await {
                if ws_write.send(msg).await.is_err() {
                    break; // WebSocket connection closed
                }
            }
        });

        // Spawn heartbeat/ping task
        let tx_clone = self.tx.clone();
        let is_connected_heartbeat = self.is_connected.clone();
        let heartbeat_handle = tokio::spawn(async move {
            let mut interval = interval(Duration::from_secs(30)); // Send ping every 30 seconds
            
            loop {
                interval.tick().await;
                
                if !*is_connected_heartbeat.lock().await {
                    break; // Stop if not connected
                }

                if let Some(tx) = &*tx_clone.lock().await {
                    if tx.unbounded_send(Message::Ping(vec![].into())).is_err() {
                        // Ping failed, connection likely broken
                        let mut connected = is_connected_heartbeat.lock().await;
                        *connected = false;
                        break;
                    }
                } else {
                    // No sender available, stop heartbeat
                    break;
                }
            }
        });

        // Store the task handles
        {
            let mut task_handles = self.connection_task_handle.lock().await;
            if let Some(handle) = task_handles.take() {
                handle.abort(); // Cancel previous tasks if any
            }
        }

        // Combine all tasks using a select to handle all of them
        let combined_handle = tokio::spawn(async move {
            // Wait for either the read or write task to complete
            tokio::select! {
                _ = read_handle => {},
                _ = write_handle => {},
                _ = heartbeat_handle => {},
            }
        });
        
        {
            let mut task_handles = self.connection_task_handle.lock().await;
            *task_handles = Some(combined_handle);
        }

        Ok(())
    }

    pub async fn disconnect(&self) -> Result<()> {
        // Cancel all tasks
        if let Some(handle) = self.connection_task_handle.lock().await.take() {
            handle.abort();
        }

        // Close the sender
        {
            let mut tx_lock = self.tx.lock().await;
            *tx_lock = None;
        }

        // Update connection status
        {
            let mut connected = self.is_connected.lock().await;
            *connected = false;
        }

        Ok(())
    }

    pub async fn send_message(&self, message: String) -> Result<()> {
        if !*self.is_connected.lock().await {
            return Err(anyhow::anyhow!("Not connected"));
        }

        if let Some(tx) = &*self.tx.lock().await {
            tx.unbounded_send(Message::Text(message.into()))
                .map_err(|e| anyhow::anyhow!("Failed to send message: {}", e))?;
        } else {
            return Err(anyhow::anyhow!("Not connected"));
        }
        Ok(())
    }

    pub async fn subscribe_to_channel(&self, channel_name: String, channel_id: String) -> Result<()> {
        let msg = serde_json::json!({
            "type": "connect",
            "body": {
                "channel": channel_name,
                "id": channel_id,
            }
        });
        
        self.send_message(msg.to_string()).await
    }

    pub async fn unsubscribe_from_channel(&self, channel_id: String) -> Result<()> {
        let msg = serde_json::json!({
            "type": "disconnect",
            "body": {
                "id": channel_id,
            }
        });
        
        self.send_message(msg.to_string()).await
    }

    // Synchronous method for Dart to poll for events
    #[frb(sync)]
    pub fn poll_event(&self) -> Option<StreamEvent> {
        // Use a blocking approach to try to receive an event
        // Since we can't directly access the receiver from a sync context,
        // we'll temporarily replace it with a new one and return the old one
        let mut rx_option = self.poll_rx.lock().unwrap().take();
        if let Some(mut rx) = rx_option {
            // Try to receive an event without blocking
            match rx.try_recv() {
                Ok(event) => {
                    // Put the receiver back
                    *self.poll_rx.lock().unwrap() = Some(rx);
                    Some(event)
                }
                Err(_) => {
                    // No event available, put the receiver back
                    *self.poll_rx.lock().unwrap() = Some(rx);
                    None
                }
            }
        } else {
            None
        }
    }

    #[frb(sync)]
    pub fn is_currently_connected(&self) -> bool {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            *self.is_connected.lock().await
        })
    }
}