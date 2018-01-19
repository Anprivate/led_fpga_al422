/* 
 *  command line for preparing video
 *  ffmpeg -i "P:\downloads\Thanks, Smokey!.mp4" -vf "scale=64:-1,crop=64:32" -pix_fmt rgb565 -c:v rawvideo -f rawvideo -y e:\output_rawvideo.raw
*/

#include "LED_PANEL.h"
#include <libmaple/dma.h>
#include <SPI.h>
#include "SdFat.h"
//#include "FreeStack.h"

#define file_name "video2.raw"
#define fps   24
#define ms_per_frame  (1000/fps)

#define width 64
#define height 32
#define bpp 3

#define scan_lines  16
#define RGB_inputs  2
#define WE_out_pin      PB10

LED_PANEL led_panel = LED_PANEL(width, height, bpp, scan_lines, RGB_inputs, WE_out_pin);

#define bytes_in_frame (width * height * 2)
uint16_t frame_buffer[bytes_in_frame / 2];

SdFat sd2(2);
// SdFatEX sd2(2);
const uint8_t SD2_CS = PB12;   // chip select for sd2
File video_file;
bool no_sd;
uint32_t file_size;
unsigned long last_frame_indicated_at;

void setup() {
  Serial.begin(9600);

  no_sd = false;
  if (!sd2.begin(SD2_CS, SD_SCK_MHZ(18))) {
    Serial.println("sd init failed");
    no_sd = true;
  }

  video_file = sd2.open(file_name, FILE_READ);
  if (!video_file) {
    Serial.println("open failed");
    no_sd = true;
  }
  /*
    file_size = video_file.file_size;
    Serial.println(file_size);
  */
  pinMode(PC13, OUTPUT);

  led_panel.begin();
  led_panel.clear();
  led_panel.show(false);
  last_frame_indicated_at = millis();
}

void loop() {
  digitalWrite(PC13, LOW);

  led_panel.clear();

  //  led_panel.drawPixel(0, 0, led_panel.Color(br, br, br));
  if (no_sd) {
    led_panel.setCursor(1, 1);
    led_panel.setTextColor(led_panel.Color(80, 80, 0));
    led_panel.setTextSize(1);
    led_panel.setTextWrap(false);
    led_panel.print("SD error");
  } else {
    int bytes_readed = video_file.read(frame_buffer, bytes_in_frame);
    if (bytes_readed < bytes_in_frame) {
      video_file.rewind();
      bytes_readed = video_file.read(frame_buffer, bytes_in_frame);
    }

    uint16_t * tmp_ptr;
    tmp_ptr = frame_buffer;
    for (uint16_t y = 0; y < height; y++) {
      for (uint16_t x = 0; x < width; x++) {
        led_panel.drawPixel(x, y, *tmp_ptr++);
      }
    }
  }

  unsigned long from_last_frame = millis() - last_frame_indicated_at;
  if (from_last_frame < ms_per_frame)
    delay(ms_per_frame - from_last_frame);

  led_panel.show(false);
  last_frame_indicated_at = millis();

  digitalWrite(PC13, HIGH);

  delay(10);
}

