#include "LED_PANEL.h"

#define width 32
#define height 32
#define bpp 2

#define scan_lines  8
#define RGB_inputs  2

LED_PANEL led_panel = LED_PANEL(width, height, bpp, scan_lines, RGB_inputs);

uint16_t x_coord = 0;
uint16_t y_coord = 0;
uint16_t preloader = 0;
uint8_t what_write = 0x08;

void setup() {
  //  Serial.begin(115200);
  pinMode(PC13, OUTPUT);

  led_panel.begin();
  led_panel.clear();
}

void loop() {
  digitalWrite(PC13, LOW);

  uint8_t br = 0x08;

  led_panel.drawCircle(16, 16, 10, led_panel.Color(0, 0, br));

  led_panel.setCursor(1, 1);
  led_panel.setTextColor(led_panel.Color(br, 0, 0));
  led_panel.setTextSize(1);
  led_panel.setTextWrap(false);
  led_panel.print("Test");

  led_panel.setCursor(4, 11);
  led_panel.setTextColor(led_panel.Color(0, br, 0));
  led_panel.print("Best");

  led_panel.setCursor(7, 21);
  led_panel.setTextColor(led_panel.Color(br, br, br));
  led_panel.print("Case");

  led_panel.show();

  digitalWrite(PC13, HIGH);
  x_coord++;
  y_coord++;
  if (x_coord >= width) {
    x_coord = 0;
    y_coord = 0;
  }
  delay(50);
}


