#include <wiringPi.h>
#include <wiringPiI2C.h>
#include <bcm2835.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

// --- LCD Definitions ---
#define ADDRESS 0x27
#define BACKLIGHT 0x08
#define ENABLE 0x04
#define CMD_MODE 0x00
#define CHAR_MODE 0x01
int lcd;

// --- Buzzer Definitions ---
#define BUZZER_PIN 23

// --- ADC (AD7193) Definitions ---
#define AD7193_REG_COMM  0x00
#define AD7193_REG_MODE  0x01
#define AD7193_REG_CONF  0x02
#define AD7193_REG_DATA  0x03
#define AD7193_REG_STAT  0x00
#define AD7193_COMM_READ 0x40
#define AD7193_COMM_WRITE 0x00
#define AD7193_COMM_ADDR(x) (((x) & 0x7) << 3)
#define MODE_IDLE    0x080000
#define MODE_SINGLE  0x200060
#define CONFIG_CH0_GAIN1 0x307009

// --- LCD Functions ---
void enable_switch(int data) {
    int enable_on = data | ENABLE;
    int enable_off = data & ~ENABLE;
    wiringPiI2CWrite(lcd, enable_on);
    usleep(500);
    wiringPiI2CWrite(lcd, enable_off);
    usleep(500);
}

void send_byte(int bits, int mode) {
    int high = mode | (bits & 0xF0) | BACKLIGHT;
    int low = mode | ((bits << 4) & 0xF0) | BACKLIGHT;
    wiringPiI2CWrite(lcd, high);
    enable_switch(high);
    wiringPiI2CWrite(lcd, low);
    enable_switch(low);
}

void lcd_init() {
    send_byte(0x33, CMD_MODE);
    send_byte(0x32, CMD_MODE);
    send_byte(0x28, CMD_MODE);
    send_byte(0x0C, CMD_MODE);
    send_byte(0x06, CMD_MODE);
    send_byte(0x01, CMD_MODE);
    usleep(2000);
}

void cursor(int line) {
    int addr = (line == 1) ? 0xC0 : 0x80;
    send_byte(addr, CMD_MODE);
}

void print(const char* str) {
    while (*str) {
        send_byte(*str++, CHAR_MODE);
    }
}

void scroll(const char* str) {
    int len = strlen(str);
    char buf[17];
    if (len <= 16) {
        cursor(0);
        print(str);
        return;
    }
    for (int i = 0; i <= len - 16; i++) {
        strncpy(buf, &str[i], 16);
        buf[16] = '\0';
        cursor(0);
        print(buf);
        usleep(300000);
    }
}

// --- SPI ADC Functions ---
void spi_write(uint8_t reg, uint32_t value, uint8_t length) {
    uint8_t tx[4] = { AD7193_COMM_WRITE | AD7193_COMM_ADDR(reg), 0, 0, 0 };
    for (int i = 0; i < length; i++) {
        tx[i + 1] = (value >> (8 * (length - 1 - i))) & 0xFF;
    }
    bcm2835_spi_writenb((char *)tx, length + 1);
}

uint32_t spi_read(uint8_t reg, uint8_t length) {
    uint8_t tx[5] = { AD7193_COMM_READ | AD7193_COMM_ADDR(reg), 0, 0, 0, 0 };
    uint8_t rx[5] = { 0 };
    bcm2835_spi_transfernb((char *)tx, (char *)rx, length + 1);
    uint32_t result = 0;
    for (int i = 1; i <= length; i++) {
        result = (result << 8) | rx[i];
    }
    return result;
}

int wait_for_rdy(int timeout_ms) {
    while ((spi_read(AD7193_REG_STAT, 1) & 0x80) && --timeout_ms) {
        usleep(1000);
    }
    return timeout_ms > 0;
}

uint32_t read_single_sample() {
    spi_write(AD7193_REG_MODE, MODE_IDLE, 3);
    usleep(5000);
    spi_write(AD7193_REG_MODE, MODE_SINGLE, 3);
    if (!wait_for_rdy(5000)) return 0xFFFFFFFF;
    return spi_read(AD7193_REG_DATA, 3);
}

// --- Buzzer Tone Functions ---
void playTone(int frequency, int duration_ms) {
    int halfPeriod = 500000 / frequency;
    int cycles = frequency * duration_ms / 1000;
    for (int i = 0; i < cycles; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        usleep(halfPeriod);
        digitalWrite(BUZZER_PIN, LOW);
        usleep(halfPeriod);
    }
}

void playHappyChime() {
    playTone(262, 150); usleep(50000);
    playTone(330, 150); usleep(50000);
    playTone(392, 150); usleep(50000);
    playTone(523, 300);
}

void playSadChime() {
    playTone(440, 300); usleep(50000);
    playTone(349, 300); usleep(50000);
    playTone(294, 300); usleep(50000);
    playTone(262, 400);
}

// --- Main ---
int main() {
    // Init I2C LCD
    wiringPiSetup();
    lcd = wiringPiI2CSetup(ADDRESS);
    if (lcd == -1) {
        printf("I2C init failed\n");
        return -1;
    }
    lcd_init();

    // Init SPI ADC
    if (!bcm2835_init() || !bcm2835_spi_begin()) {
        printf("SPI init failed\n");
        return 1;
    }
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_128);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
    uint8_t reset[5] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    bcm2835_spi_writenb((char *)reset, 5);
    usleep(5000);
    spi_write(AD7193_REG_CONF, CONFIG_CH0_GAIN1, 3);
    usleep(90000);

    // Init GPIO Buzzer
    wiringPiSetupGpio();
    pinMode(BUZZER_PIN, OUTPUT);

    time_t lastHappy = 0, lastSad = 0;

    while (1) {
        uint32_t data = read_single_sample();
        if (data == 0xFFFFFFFF) {
            scroll("Error: ADC read fail");
        } else {
            int isMoist = (data > 0x700000); // adjust threshold experimentally
            time_t now = time(NULL);

            if (isMoist) {
                scroll("Soil is moist. No watering needed.");
                if (now - lastHappy >= 10) {
                    playHappyChime();
                    lastHappy = now;
                }
            } else {
                scroll("Attention: Water the plant!");
                if (now - lastSad >= 10) {
                    playSadChime();
                    lastSad = now;
                }
            }
        }

        usleep(500000);
    }

    bcm2835_spi_end();
    bcm2835_close();
    return 0;
}
