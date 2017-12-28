#include "LED_PANEL.h"
#include <libmaple/dma.h>

#define width 32
#define height 32
#define bpp 2

#define scan_lines  8
#define RGB_inputs  2
#define WE_out_pin      PB10
#define WE_out_pin2      PB11

LED_PANEL led_panel = LED_PANEL(width, height, bpp, scan_lines, RGB_inputs, WE_out_pin);
LED_PANEL led_panel2 = LED_PANEL(width, height, bpp, scan_lines, RGB_inputs, WE_out_pin2);

uint16_t x_coord = 0;
uint16_t y_coord = 0;
uint16_t preloader = 0;
uint8_t what_write = 0x08;

void setup() {
  //  Serial.begin(115200);
  pinMode(PC13, OUTPUT);

  led_panel.begin();
  led_panel.clear();
  
  led_panel2.begin();
  led_panel2.clear();
}

void loop() {
  digitalWrite(PC13, LOW);

  uint8_t br = 0x08;

  led_panel.clear();
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

  led_panel.show(true);

  led_panel2.clear();
  led_panel2.drawCircle(16, 16, 10, led_panel.Color(0, 0, br));
  led_panel2.show(true);
  
  digitalWrite(PC13, HIGH);
  delay(10);
  /*
    delay(5000);

    led_panel.clear();
    for (uint16_t i = 0; i < width; i++) {
      uint8_t c = i << 2;
      uint8_t c2 = c + 128;

      led_panel.drawPixel(i, 0, led_panel.Color(0, 0, c));
      led_panel.drawPixel(i, 1, led_panel.Color(0, 0, c2));
      led_panel.drawPixel(i, 2, led_panel.Color(0, c, 0));
      led_panel.drawPixel(i, 3, led_panel.Color(0, c2, 0));
      led_panel.drawPixel(i, 4, led_panel.Color(c, 0, 0));
      led_panel.drawPixel(i, 5, led_panel.Color(c2, 0, 0));
      led_panel.drawPixel(i, 6, led_panel.Color(c, c, c));
      led_panel.drawPixel(i, 7, led_panel.Color(c2, c2, c2));
      led_panel.drawPixel(i, 8, led_panel.Color(0, 255 - c, c));
      led_panel.drawPixel(i, 9, led_panel.Color(0, 255 - c2, c2));
      led_panel.drawPixel(i, 10, led_panel.Color(255 - c, 0, c));
      led_panel.drawPixel(i, 11, led_panel.Color(255 - c2, 0, c2));
      led_panel.drawPixel(i, 12, led_panel.Color(255 - c, c, 0));
      led_panel.drawPixel(i, 13, led_panel.Color(255 - c2, c2, 0));
    }

    led_panel.show();

    delay(5000); */
}


