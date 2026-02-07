#include <DHT.h>
#include <WiFi.h>

#define DHTPIN 4
#define DHTTYPE DHT11
#define LDR_AO_PIN 2
#define SMPIN 5

#ifndef STASSID
#define STASSID "Lolz"
#define STAPSK "kxvt9000"
#endif

DHT dht(DHTPIN,DHTTYPE);

const char* ssid = STASSID;
const char* password = STAPSK;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Hello, ESP32!");
  scan();
  connectWIFI(ssid, password); // add password when working with Lolz
  Serial.println("TESTY BESTY:");
  dht.begin();
}


float dhtData(DHT dht){
  float h = dht.readHumidity();
  // Read temperature as Celsius
  float t = dht.readTemperature();
  Serial.println("hum:");
  Serial.print(h);
  Serial.println("tep:");
  Serial.print(t);

  return t, h;
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

float lightData(int AO_PIN){
  float lVal = analogRead(AO_PIN);
  Serial.print("Light val = ");
  Serial.println(lVal);

  return lVal;
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(2000); // this speeds up the simulation
  dhtData(dht);
  lightData(LDR_AO_PIN);
}
