#include <ArduinoJson.h>
#include <ArduinoJson.hpp>
#include <MQTTClient.h>
#include <DHT.h>
#include <WiFi.h>


#define DHTPIN 4
#define DHTTYPE DHT11
#define LDR_AO_PIN 2
#define SMPIN 5
#define DRY 1000

#ifndef STASSID
#define STASSID "Lolz"
#define STAPSK "kxvt9000"
#endif

DHT dht(DHTPIN,DHTTYPE);

const char* ssid = STASSID;
const char* password = STAPSK;

const char* mqttBroker = "test.mosquitto.org";
const int mqttPort = 1883;
const char mqttClient[] = "bingbong";

const char publishTopic[] = "bingbong/sdata";
const char subscribeTopic[] = "bingbong/sdata";

const int publishInterval = 5000;

WiFiClient network;
MQTTClient mqtt = MQTTClient(256);

unsigned long lastPubTime = 0;



void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Hello, ESP32!");
  scan();
  connectWIFI(ssid, password); // add password when working with Lolz
  Serial.println("TESTY BESTY:");
  dht.begin();
}

void connectWIFI(const char* ssid, const char* pass){ //add pass when working with Lolz
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass); //add pass when working with Lolz
  Serial.println("");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  
  connectMQTT();
}

void scan()
{
    Serial.println("Scan start");

    // WiFi.scanNetworks will return the number of networks found.
    int n = WiFi.scanNetworks();
    Serial.println("Scan done");
    if (n == 0) {
        Serial.println("no networks found");
    } else {
        Serial.print(n);
        Serial.println(" networks found");
        Serial.println("Nr | SSID                             | RSSI | CH | Encryption");
        for (int i = 0; i < n; ++i) {
            // Print SSID and RSSI for each network found
            Serial.printf("%2d",i + 1);
            Serial.print(" | ");
            Serial.printf("%-32.32s", WiFi.SSID(i).c_str());
            Serial.print(" | ");
            Serial.printf("%4d", WiFi.RSSI(i));
            Serial.print(" | ");
            Serial.printf("%2d", WiFi.channel(i));
            Serial.print(" | ");
            switch (WiFi.encryptionType(i))
            {
            case WIFI_AUTH_OPEN:
                Serial.print("open");
                break;
            case WIFI_AUTH_WEP:
                Serial.print("WEP");
                break;
            case WIFI_AUTH_WPA_PSK:
                Serial.print("WPA");
                break;
            case WIFI_AUTH_WPA2_PSK:
                Serial.print("WPA2");
                break;
            case WIFI_AUTH_WPA_WPA2_PSK:
                Serial.print("WPA+WPA2");
                break;
            case WIFI_AUTH_WPA2_ENTERPRISE:
                Serial.print("WPA2-EAP");
                break;
            case WIFI_AUTH_WPA3_PSK:
                Serial.print("WPA3");
                break;
            case WIFI_AUTH_WPA2_WPA3_PSK:
                Serial.print("WPA2+WPA3");
                break;
            case WIFI_AUTH_WAPI_PSK:
                Serial.print("WAPI");
                break;
            default:
                Serial.print("unknown");
            }
            Serial.println();
            delay(10);
        }
    }
    Serial.println("");
}

struct daa{
  float h;
  float t;
};

struct daa dhtData(DHT dht){
  struct daa lol;
  lol.h = dht.readHumidity();
  // Read temperature as Celsius
  lol.t = dht.readTemperature();
  Serial.print("hum:");
  Serial.println(lol.h);
  Serial.print("tep:");
  Serial.println(lol.t);


  return lol;
}

float lightData(int AO_PIN){
  float lVal = analogRead(AO_PIN);
  Serial.print("Light val = ");
  Serial.println(lVal);

  return lVal;
}

float sm(int AO_PIN){
  float smVal = analogRead(AO_PIN);

  return smVal;
}

char* smDetermine(int AO_PIN, float THRESHHOLD){
    float smVal = sm(AO_PIN);
    if (smVal > THRESHHOLD){
        char* smFeel = "DRY";
        Serial.print("Soil is ");
        Serial.println(smFeel);
        return smFeel;
    }
    else{
        char* smFeel = "WET";
        Serial.print("Soil is ");
        Serial.println(smFeel);
        return smFeel;
    }

    Serial.println(smVal);
}

void loop() {
    mqtt.loop();

  // put your main code here, to run repeatedly:
  delay(2000); // this speeds up the simulation
  struct daa lol;
  lol = dhtData(dht);
  float litVal = lightData(LDR_AO_PIN);
  float smval = sm(SMPIN);
  char* smfeel = smDetermine(SMPIN,DRY);

    if (millis() - lastPubTime > publishInterval){
        sendMQTT(lol,litVal,smfeel);
        lastPubTime = millis();
    }
}

void connectMQTT() {
    mqtt.begin(mqttBroker,mqttPort, network);
    // mqtt.onMessage(messageHandler);
    Serial.print("Connecting to Broker");

    while (!mqtt.connect(mqttClient)) {
    Serial.print(".");
    delay(100);
    }
    Serial.println();

    if (!mqtt.connected()){
      Serial.println("Broker timeout");
    return;
    }

    // if (mqtt.subscribe(subscribeTopic))
    //   Serial.print("Subscribed to the topic: ");
    // else
    //   Serial.print("Failed to subscribe to the topic: ");

    // Serial.println(subscribeTopic);
    // Serial.println("MQTT broker Connected!");
}

void sendMQTT(struct daa lol,float lVal,char* smFeel){
    StaticJsonDocument<200> middlefinger;
    middlefinger["timestamp"] = millis();
    middlefinger["temp"] = lol.t;
    middlefinger["humidity"] = lol.h;
    middlefinger["light"] = lVal;
    middlefinger["soil moisture"] = smFeel;
    char messageBuffer[512];
    serializeJson(middlefinger, messageBuffer);
    
    mqtt.publish(publishTopic, messageBuffer);

    Serial.println("Sent to MQTT");
    Serial.print("- topic:");
    Serial.println(publishTopic);
    Serial.print("- payload:");
    Serial.println(messageBuffer);

}

// void messageHandler(String &topic, String &payload){
//     Serial.println("Received from MQTT");
//     Serial.println("- topic " + topic);
//     Serial.println("- payload " + payload);
    
// }
