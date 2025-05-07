##########################################################
# Name: main.c
# Date: 05/06/2025
# Created by: Evan Broberg, Leslie Torres, Rucha Damle
#
# This program is the main driver code for our project,
# the Moisture Maestro. It measures the moisture level on
# a potted houseplant through a soil moisture sensor.
# If the soil is dry, a message telling the user to water
# their plant will be displayed on an LCD display, and a 
# buzzer will play a sad chime. If the soil is adequately
# moist, a message telling the user their plant does not
# need watering will be displayed on the LCD, and a buzzer
# will play a happy chime.
##########################################################

// Include Required Libraries
#include <wiringPi.h>           // For GPIO functions
#include <wiringPiI2C.h>        // For I2C communication (LCD)
#include <bcm2835.h>            // For SPI communication (AD7193)
#include <stdio.h>              // Standard I/O
#include <stdint.h>             // For fixed-width integer types
#include <unistd.h>             // For usleep() 
#include <string.h>             // For string handling
#include <time.h>               // For time functions

// Definitions for LCD 1602 display
#define ADDRESS 0x27            // I2C address of the LCD display
#define BACKLIGHT 0x08          // Bit to control LCD backlight
#define ENABLE 0x04             // Bit to toggle the enable pin (signals LCD to read data)
#define CMD_MODE 0x00           // Command mode for control instructions
#define CHAR_MODE 0x01          // Character mode for printing text
int lcd;                        // Global variable for the LCD device descriptor

// Definitions for buzzer
#define BUZZER_PIN 23           // GPIO pin number for buzzer 

// Definitions for SPI ADC
#define AD7193_REG_COMM  0x00   // Communications register
#define AD7193_REG_MODE  0x01   // Mode register
#define AD7193_REG_CONF  0x02   // Configuration register
#define AD7193_REG_DATA  0x03   // Data register
#define AD7193_REG_STAT  0x00   // Status register
#define AD7193_COMM_READ 0x40   // Bit to indicate a read command
#define AD7193_COMM_WRITE 0x00  // Bit to indicate a write command
#define AD7193_COMM_ADDR(x) (((x) & 0x7) << 3)  // Macro to compute register address bits

#define MODE_IDLE    0x080000   // Mode register value for idle state
#define MODE_SINGLE  0x200060   // Single conversion mode
#define CONFIG_CH0_GAIN1 0x307009 // Sets up the ADC to read from channel 0

/////////////////////////// LCD Functions ///////////////////////////////

/**
 * @brief Pulses the LCD's ENABLE pin to signal that data is ready
 *
 * This function toggles the ENABLE bit high and then low to let the LCD
 * know it should read the current command or character from the data lines.
 * This is required every time we send something to the LCD (either a command or a character).
 *
 * @param data The full byte to send to the LCD, including control bits 
 *             (like a command, character, backlight setting etc)
 */
void enable_switch(int data) {
    // This sequence lets the LCD know it should read the current command/character
    // Set the ENABLE bit high
    int enable_on = data | ENABLE;     
    // Set the ENABLE bit low
    int enable_off = data & ~ENABLE;   

    // Send high signal
    wiringPiI2CWrite(lcd, enable_on);   
    usleep(500);
    // Send low signal
    wiringPiI2CWrite(lcd, enable_off); 
    usleep(500);                      
}

/**
 * @brief Sends a byte to the LCD in 4-bit mode (as two nibbles)
 *
 * @param bits The 8-bit value (ASCII char or LCD command) to send
 * @param mode Use CMD_MODE for commands or CHAR_MODE for printable characters
 *
 * @note One nibble = half a byte (4 bits)
 */
void send_byte(int bits, int mode) {
    // Two nibbles since LCD can only recieve 4 bits at a time
    int high_nibble = mode | (bits & 0xF0) | BACKLIGHT;
    int low_nibble  = mode | ((bits << 4) & 0xF0) | BACKLIGHT;

    // Send the nibble
    wiringPiI2CWrite(lcd, high_nibble);
    // Then enable switch to read nibble
    enable_switch(high_nibble);

    wiringPiI2CWrite(lcd, low_nibble);
    enable_switch(low_nibble);
}

/**
 * @brief Initializes the LCD to prepare the display
 */
void lcd_init() {
    // Set to 8-bit mode
    send_byte(0x33, CMD_MODE);
    // Switch to 4-bit mode
    send_byte(0x32, CMD_MODE);
    // Set the LCD to have 2 lines w/ 5x8 font
    send_byte(0x28, CMD_MODE); 
    // Turn on display
    send_byte(0x0C, CMD_MODE);
    // Move the cursor right
    send_byte(0x06, CMD_MODE); 
    // Clear display
    send_byte(0x01, CMD_MODE); 
    usleep(2000);               
}

/**
 * @brief Moves the LCD cursor to the start of the specified line
 *
 * @param line Line number, 0 for top line and 1 for bottom line
 */
void cursor(int line) {
    int address;
    if (line == 1) {
        address = 0xC0;
    } else {
        address = 0x80;
    }
    send_byte(address, CMD_MODE);
}

/**
 * @brief Prints a string to the LCD.
 *
 * @param str Pointer to the string to print.
 *
 * @note The string is written starting from the cursor position.
 */
void print(const char* str) {
    while (*str) {
        send_byte(*str++, CHAR_MODE);
    }
}

/**
 * @brief Scrolls a long string across the first line of the LCD.
 *
 * @param str Pointer to the long string to scroll.
 */
void scroll(const char* str) {
    int len = strlen(str);
    // buffer for 16 chars + a null terminator to end the string
    char buf[17];  ///< Buffer for 16 characters + null terminator

    // if the length of the string is less than 16 chars, print string directly
    if (len <= 16) {
        cursor(0);
        print(str);
        return;
    }

    // otherwise, print the string in a scrolling fashion
    for (int i = 0; i <= len - 16; i++) {
        strncpy(buf, &str[i], 16);
        buf[16] = '\0';

        cursor(0);
        print(buf);
        // add in a slight delay between scrolls
        usleep(300000); 
    }
}


////////////////////////////// ADC Functions /////////////////////////////

// Write a multi-byte value to a register over SPI
void spi_write(uint8_t reg, uint32_t value, uint8_t length) {
    uint8_t tx[4] = { AD7193_COMM_WRITE | AD7193_COMM_ADDR(reg), 0, 0, 0 };
    for (int i = 0; i < length; i++) {
        tx[i + 1] = (value >> (8 * (length - 1 - i))) & 0xFF;
    }
    bcm2835_spi_writenb((char *)tx, length + 1);
}

// Read a multi-byte value from a register over SPI
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

// Wait until ADC signals data is ready or timeout (in ms)
int wait_for_rdy(int timeout_ms) {
    while ((spi_read(AD7193_REG_STAT, 1) & 0x80) && --timeout_ms) {
        usleep(1000);  // Poll every 1 ms
    }
    return timeout_ms > 0;  // Return success/failure
}

// Trigger one ADC sample and return the result
uint32_t read_single_sample() {
    spi_write(AD7193_REG_MODE, MODE_IDLE, 3);     // Set to idle
    usleep(5000);
    spi_write(AD7193_REG_MODE, MODE_SINGLE, 3);   // Start single conversion
    if (!wait_for_rdy(5000)) return 0xFFFFFFFF;   // Timeout
    return spi_read(AD7193_REG_DATA, 3);          // Read result
}

////////////////////////// Buzzer Functions ///////////////////////////////////

/**
 * @brief Plays a single tone on the buzzer.
 *
 * @param frequency Frequency of the tone in Hz
 * @param duration_ms Duration of the tone in milliseconds
 */
void playTone(int frequency, int duration_ms) {
    // Calculate the delay for half cycle in microseconds
    // 1 second = 1,000,000 microseconds, so half of 1 cycle 
    // is 500,000 seconds
    int halfPeriod = 500000 / frequency; 
    // Total cycles to generate the tone for
    int cycles = frequency * duration_ms / 1000;

    for (int i = 0; i < cycles; i++) {
        digitalWrite(BUZZER_PIN, HIGH); // Turn buzzer on
        usleep(halfPeriod);             // Wait half a period
        digitalWrite(BUZZER_PIN, LOW);  // Turn the buzzer off
        usleep(halfPeriod);             // Wait half a period
    }
}

/**
 * @brief Plays a cheerful jingle with 4 notes.
 *
 * Each note is followed by a short pause to improve clarity.
 * Without this pause, the notes bleed into one another.
 */
void playHappyChime() {
    playTone(262, 150);
    usleep(50000);
    playTone(330, 150); 
    usleep(50000);
    playTone(392, 150); 
    usleep(50000);
    playTone(523, 300); 
}

/**
 * @brief Plays a sad jingle with 4 notes.
 *
 * Each note is followed by a short pause to improve clarity. 
 * Without this pause, the notes bleed into one another.
 */
void playSadChime() {
    playTone(440, 300); 
    usleep(50000);
    playTone(349, 300); 
    usleep(50000);
    playTone(294, 300); 
    usleep(50000);
    playTone(262, 400);
}

int main() {
    // Initialize LCD
    wiringPiSetup();    
    // Init wiringPi with default numbering
    lcd = wiringPiI2CSetup(ADDRESS);            
    // Open I2C connection to LCD
    if (lcd == -1) {
        printf("I2C init failed\n");
        return -1;
    }
    lcd_init();

    // Initialize SPI for ADC
    if (!bcm2835_init() || !bcm2835_spi_begin()) {
        printf("SPI init failed\n");
        return 1;
    }
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_128);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);

    // Send reset command (5 bytes of 0xFF)
    uint8_t reset[5] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    bcm2835_spi_writenb((char *)reset, 5);
    usleep(5000);

    // Configure ADC input settings
    spi_write(AD7193_REG_CONF, CONFIG_CH0_GAIN1, 3);
    usleep(90000);  

    // Initialize buzzer GPIO pin
    wiringPiSetupGpio();       
    pinMode(BUZZER_PIN, OUTPUT);

    // Track the last chime times
    time_t lastHappy = 0
    time_t lastSad = 0;

    // Main loop
    // Infinite loop
    while (1) {
        // Get ADC reading
        uint32_t data = read_single_sample(); 
        if (data == 0xFFFFFFFF) {
            scroll("Error: ADC read fail");
        } else {
            // Considered moist if reading is less than or equal to 430
            int isMoist = (data <= 430);      
            time_t now = time(NULL);

            if (isMoist) {
                scroll("Soil is moist. No watering needed.");
                // Only play buzzer chime every 10 secs
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

        usleep(500000);  // Loop delay (0.5 sec)
    }

    // Cleanup
    // This code is never reachable due to the infinite loop, but is good practice
    bcm2835_spi_end();
    bcm2835_close();
    return 0;
}
