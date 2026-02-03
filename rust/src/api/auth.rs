use anyhow::Result;
use flutter_rust_bridge::frb;
use reqwest::Client;

#[frb(opaque)]
pub struct JuheAuthClient {
    appid: String,
    appkey: String,
    apiurl: String,
    callback: String,
    client: Client,
}

impl JuheAuthClient {
    #[frb(sync)]
    pub fn new(appid: String, appkey: String, apiurl: String, callback: String) -> JuheAuthClient {
        let client = Client::builder()
            .user_agent("CyaniTalk/1.0 (Rust)")
            .danger_accept_invalid_certs(true) // Matching Dart's badCertificateCallback
            .build()
            .unwrap_or_default();
            
        JuheAuthClient {
            appid,
            appkey,
            apiurl,
            callback,
            client,
        }
    }

    pub async fn get_login_url(&self, type_: String, state: String) -> Result<String> {
        let url = format!("{}connect.php", self.apiurl);
        let params = [
            ("act", "login"),
            ("appid", &self.appid),
            ("appkey", &self.appkey),
            ("type", &type_),
            ("redirect_uri", &self.callback),
            ("state", &state),
        ];

        let response = self.client.get(&url)
            .query(&params)
            .send()
            .await?;
            
        let text = response.text().await?;
        Ok(text)
    }

    pub async fn callback_auth(&self, code: String) -> Result<String> {
        let url = format!("{}connect.php", self.apiurl);
        let params = [
            ("act", "callback"),
            ("appid", &self.appid),
            ("appkey", &self.appkey),
            ("code", &code),
        ];

        let response = self.client.get(&url)
            .query(&params)
            .send()
            .await?;
            
        let text = response.text().await?;
        Ok(text)
    }
    
    pub async fn query_user(&self, type_: String, social_uid: String) -> Result<String> {
        let url = format!("{}connect.php", self.apiurl);
        let params = [
            ("act", "query"),
            ("appid", &self.appid),
            ("appkey", &self.appkey),
            ("type", &type_),
            ("social_uid", &social_uid),
        ];

        let response = self.client.get(&url)
            .query(&params)
            .send()
            .await?;
            
        let text = response.text().await?;
        Ok(text)
    }
}
