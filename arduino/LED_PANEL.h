#ifndef FPGA_LED_PANEL
#define FPGA_LED_PANEL

#if ARDUINO >= 100
#include <Arduino.h>
#else
#include <WProgram.h>
#include <pins_arduino.h>
#endif

#include <libmaple/dma.h>
#include <Adafruit_GFX.h>

// clk_out is PB0. It is Timer 3 ch 3 PWM out
#define clk_out PB0
// rst_out is PB1
#define rst_out PB1
// data_port
#define data_port GPIOA

class LED_PANEL : public Adafruit_GFX {
  public:
    LED_PANEL (uint16_t width, uint16_t height, uint8_t bytes_per_pixel, uint8_t scan_lines, uint8_t RGB_inputs, uint8_t we_pin); // Constuctor
    ~LED_PANEL();
    void begin(void);
    void clear(void);
    boolean show(void);
    void show(boolean WaitForFinish);
    void setPixelColor(uint16_t x, uint16_t y, uint8_t r, uint8_t g, uint8_t b);
    void drawPixel(int16_t x, int16_t y, uint16_t color);
    void setPassThruColor(uint32_t c);
    void setPassThruColor(void);
    uint16_t Color(uint8_t r, uint8_t g, uint8_t b);
    boolean OutIsFree(void);
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
    uint8_t _we_pin; // we out pin
    uint16_t numLEDs;   // number of LEDs on panel
    uint16_t numBytes;  // number of bytes in buffer
    uint8_t BPP;        // bytes per pixel
    uint32_t passThruColor;
    boolean  passThruFlag = false;
    uint8_t * pixels;    // pixels data
    // private functions
    uint8_t * getPixelAddress(uint16_t x, uint16_t y);
    // static variables and functions
    static boolean begun;
    static volatile boolean dma_is_free;
    static timer_dev * timer_clk_dev;
    static uint8_t timer_clk_ch;
    static uint8_t last_we_pin;
    static void static_begin(uint8_t we_pin);
    static void static_start_transfer(uint8_t we_pin, uint8_t * pixels_array, uint16_t data_size);
    static void static_on_full_transfer(void);
};

#endif // FPGA_LED_PANEL

