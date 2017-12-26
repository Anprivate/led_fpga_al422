#include "LED_PANEL.h"
#include "gamma.h"

LED_PANEL::LED_PANEL(uint16_t width, uint16_t height, uint8_t bytes_per_pixel, uint8_t scan_lines, uint8_t RGB_inputs) : Adafruit_GFX(width, height) {
  panelWidth = width;
  panelHeight = height;
  BPP = bytes_per_pixel;
  //
  numLEDs = panelWidth * panelHeight;
  numBytes = numLEDs * BPP;
  pixels = (uint8_t *)malloc(numBytes);

  _scan_lines = scan_lines;
  _RGB_inputs = RGB_inputs;

  segmentHeight = _scan_lines * _RGB_inputs;
  segmentNum = panelHeight / segmentHeight;
}

LED_PANEL::~LED_PANEL() {
  if (pixels)
    free(pixels);
}

// Expand 16-bit input color (Adafruit_GFX colorspace) to 24-bit (NeoPixel)
// (w/gamma adjustment)
static uint32_t expandColor(uint16_t color) {
  return ((uint32_t)pgm_read_byte(&gamma5[ color >> 11       ]) << 16) |
         ((uint32_t)pgm_read_byte(&gamma6[(color >> 5) & 0x3F]) <<  8) |
         pgm_read_byte(&gamma5[ color       & 0x1F]);
}

void LED_PANEL::clear(void) {
  uint8_t * tmp_ptr = pixels;
  for (uint16_t i = 0; i < numBytes; i++)
    *tmp_ptr++ = 0x00;
}

uint8_t * LED_PANEL::getPixelAddress(uint16_t x, uint16_t y) {
  uint16_t tmp_y = y;
  uint16_t pix_num;

  if ((x >= panelWidth) || (y >= panelHeight)) return NULL;

  pix_num = x * _RGB_inputs;

  pix_num += (tmp_y % _scan_lines) * _RGB_inputs * panelWidth * segmentNum ;

  tmp_y /= _scan_lines;

  if (_RGB_inputs == 2) {
    if (tmp_y & 0x0001) pix_num++;
    tmp_y >>= 1;
  }
  pix_num += tmp_y * _RGB_inputs * panelWidth;

  return pixels + pix_num * BPP;
}

void LED_PANEL::setPixelColor(uint16_t x, uint16_t y, uint8_t r, uint8_t g, uint8_t b) {
  uint8_t * tmp_ptr = getPixelAddress(x, y);
  if (tmp_ptr == NULL) return;

  if (BPP == 3) {
    *tmp_ptr++ = b;
    *tmp_ptr++ = g;
    *tmp_ptr++ = r;
  } else {
    uint16_t tmp_c = Color(r, g, b);
    *tmp_ptr++ = tmp_c;
    *tmp_ptr++ = tmp_c >> 8;
  }
}

void LED_PANEL::drawPixel(int16_t x, int16_t y, uint16_t color) {
  if ((x < 0) || (y < 0) || (x >= panelWidth) || (y >= panelHeight)) return;

  uint8_t * tmp_ptr = getPixelAddress(x, y);
  if (tmp_ptr == NULL) return;

  if (BPP == 3) {
    uint32_t tmp_c = (passThruFlag) ? passThruColor : expandColor(color);
    *tmp_ptr++ = tmp_c;
    tmp_c >>= 8;
    *tmp_ptr++ = tmp_c;
    tmp_c >>= 8;
    *tmp_ptr++ = tmp_c;
  } else {
    uint16_t tmp_c = color;
    *tmp_ptr++ = tmp_c;
    tmp_c >>= 8;
    *tmp_ptr++ = tmp_c;
  }
}

// Pass raw color value to set/enable passthrough
void LED_PANEL::setPassThruColor(uint32_t c) {
  passThruColor = c;
  passThruFlag  = true;
}

// Call without a value to reset (disable passthrough)
void LED_PANEL::setPassThruColor(void) {
  passThruFlag = false;
}

// Downgrade 24-bit color to 16-bit
uint16_t LED_PANEL::Color(uint8_t r, uint8_t g, uint8_t b) {
  return ((uint16_t)(r & 0xF8) << 8) |
         ((uint16_t)(g & 0xFC) << 3) |
         (b >> 3);
}

void LED_PANEL::begin(void) {
  GPIOA->regs->CRL = 0x33333333;
  GPIOA->regs->CRH = 0x33333333;
  GPIOB->regs->CRL = 0x33333333;
  GPIOB->regs->CRH = 0x33333333;
}

void LED_PANEL::show(void) {
  noInterrupts();
  // 0 -> WE
  GPIOB->regs->BRR = (1 << 10);

  // 0 -> CLK
  GPIOB->regs->BRR = (1 << 0);
  // 0 -> RESET
  GPIOB->regs->BRR = (1 << 1);
  // 1 -> CLK
  GPIOB->regs->BSRR = (1 << 0);
  // 1 -> RESET
  GPIOB->regs->BSRR = (1 << 1);

  uint8_t * tmp_byte = pixels;
  uint16_t hb = GPIOA->regs->ODR & 0xFF00;
  for (uint16_t i = 0; i < numBytes; i++) {
    // 0 -> CLK
    GPIOB->regs->BRR = (1 << 0);
    // set data
    GPIOA->regs->ODR = hb | *tmp_byte++;
    // 1 -> CLK
    GPIOB->regs->BSRR = (1 << 0);
  }

  // 0 -> CLK
  GPIOB->regs->BRR = (1 << 0);
  // 0 -> RESET
  GPIOB->regs->BRR = (1 << 1);
  // 1 -> CLK
  GPIOB->regs->BSRR = (1 << 0);
  // 1 -> RESET
  GPIOB->regs->BSRR = (1 << 1);

  // 1 -> WE
  GPIOB->regs->BSRR = (1 << 10);

  // 0 -> data
  GPIOA->regs->ODR = 0;
  interrupts();
}

