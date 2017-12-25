#ifndef FPGA_LED_PANEL
#define FPGA_LED_PANEL

#if ARDUINO >= 100
#include <Arduino.h>
#else
#include <WProgram.h>
#include <pins_arduino.h>
#endif

#include <Adafruit_GFX.h>

class LED_PANEL : public Adafruit_GFX {
  public:
    LED_PANEL (uint16_t width, uint16_t height, uint8_t bytes_per_pixel, uint8_t scan_lines, uint8_t RGB_inputs); // Constuctor
    ~LED_PANEL();
    void begin(void);
    void clear(void);
    void show(void);
    void setPixelColor(uint16_t x, uint16_t y, uint8_t r, uint8_t g, uint8_t b);
    void setPixelColor16(uint16_t x, uint16_t y, uint16_t c);
    void setPixelColor32(uint16_t x, uint16_t y, uint32_t c);
    void drawPixel(int16_t x, int16_t y, uint16_t color);
    uint16_t Color(uint8_t r, uint8_t g, uint8_t b);
    /*    uint16_t numPixels(void) const;
            static uint32_t Color(uint8_t r, uint8_t g, uint8_t b),
                   Color(uint8_t r, uint8_t g, uint8_t b, uint8_t w); */
  private:
    uint16_t panelWidth; //  width of panel (total)
    uint16_t panelHeight; // height of panel (total)
    uint8_t segmentHeight; // height of one segment
    uint8_t segmentNum; // number of segments
    uint8_t _scan_lines; // lines in scan (8/16/32)
    uint8_t _RGB_inputs; // RGB inputs (1 or 2)
    uint16_t numLEDs;   // number of LEDs on panel
    uint16_t numBytes;  // number of bytes in buffer
    uint8_t BPP;        // bytes per pixel
    uint8_t *pixels;    // pixels data
    uint8_t * getPixelAddress(uint16_t x, uint16_t y);
};


#endif // FPGA_LED_PANEL

