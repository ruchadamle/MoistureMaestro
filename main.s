	.arch armv6
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"main.c"
	.text
	.global	lcd
	.bss
	.align	2
	.type	lcd, %object
	.size	lcd, 4
lcd:
	.space	4
	.text
	.align	2
	.global	enable_switch
	.arch armv6
	.syntax unified
	.arm
	.fpu vfp
	.type	enable_switch, %function
enable_switch:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-16]
	orr	r3, r3, #4
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-16]
	bic	r3, r3, #4
	str	r3, [fp, #-12]
	ldr	r3, .L2
	ldr	r3, [r3]
	ldr	r1, [fp, #-8]
	mov	r0, r3
	bl	wiringPiI2CWrite
	mov	r0, #500
	bl	usleep
	ldr	r3, .L2
	ldr	r3, [r3]
	ldr	r1, [fp, #-12]
	mov	r0, r3
	bl	wiringPiI2CWrite
	mov	r0, #500
	bl	usleep
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L3:
	.align	2
.L2:
	.word	lcd
	.size	enable_switch, .-enable_switch
	.align	2
	.global	send_byte
	.syntax unified
	.arm
	.fpu vfp
	.type	send_byte, %function
send_byte:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	ldr	r3, [fp, #-16]
	and	r2, r3, #240
	ldr	r3, [fp, #-20]
	orr	r3, r2, r3
	orr	r3, r3, #8
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-16]
	lsl	r3, r3, #4
	uxtb	r2, r3
	ldr	r3, [fp, #-20]
	orr	r3, r2, r3
	orr	r3, r3, #8
	str	r3, [fp, #-12]
	ldr	r3, .L5
	ldr	r3, [r3]
	ldr	r1, [fp, #-8]
	mov	r0, r3
	bl	wiringPiI2CWrite
	ldr	r0, [fp, #-8]
	bl	enable_switch
	ldr	r3, .L5
	ldr	r3, [r3]
	ldr	r1, [fp, #-12]
	mov	r0, r3
	bl	wiringPiI2CWrite
	ldr	r0, [fp, #-12]
	bl	enable_switch
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L6:
	.align	2
.L5:
	.word	lcd
	.size	send_byte, .-send_byte
	.align	2
	.global	lcd_init
	.syntax unified
	.arm
	.fpu vfp
	.type	lcd_init, %function
lcd_init:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r1, #0
	mov	r0, #51
	bl	send_byte
	mov	r1, #0
	mov	r0, #50
	bl	send_byte
	mov	r1, #0
	mov	r0, #40
	bl	send_byte
	mov	r1, #0
	mov	r0, #12
	bl	send_byte
	mov	r1, #0
	mov	r0, #6
	bl	send_byte
	mov	r1, #0
	mov	r0, #1
	bl	send_byte
	mov	r0, #2000
	bl	usleep
	nop
	pop	{fp, pc}
	.size	lcd_init, .-lcd_init
	.align	2
	.global	cursor
	.syntax unified
	.arm
	.fpu vfp
	.type	cursor, %function
cursor:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-16]
	cmp	r3, #1
	bne	.L9
	mov	r3, #192
	str	r3, [fp, #-8]
	b	.L10
.L9:
	mov	r3, #128
	str	r3, [fp, #-8]
.L10:
	mov	r1, #0
	ldr	r0, [fp, #-8]
	bl	send_byte
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	cursor, .-cursor
	.align	2
	.global	print
	.syntax unified
	.arm
	.fpu vfp
	.type	print, %function
print:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	str	r0, [fp, #-8]
	b	.L12
.L13:
	ldr	r3, [fp, #-8]
	add	r2, r3, #1
	str	r2, [fp, #-8]
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r1, #1
	mov	r0, r3
	bl	send_byte
.L12:
	ldr	r3, [fp, #-8]
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L13
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	print, .-print
	.align	2
	.global	scroll
	.syntax unified
	.arm
	.fpu vfp
	.type	scroll, %function
scroll:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #40
	str	r0, [fp, #-40]
	ldr	r0, [fp, #-40]
	bl	strlen
	mov	r3, r0
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-12]
	cmp	r3, #16
	bgt	.L15
	mov	r0, #0
	bl	cursor
	ldr	r0, [fp, #-40]
	bl	print
	b	.L14
.L15:
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L17
.L18:
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-40]
	add	r1, r2, r3
	sub	r3, fp, #32
	mov	r2, #16
	mov	r0, r3
	bl	strncpy
	mov	r3, #0
	strb	r3, [fp, #-16]
	mov	r0, #0
	bl	cursor
	sub	r3, fp, #32
	mov	r0, r3
	bl	print
	ldr	r0, .L19
	bl	usleep
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L17:
	ldr	r3, [fp, #-12]
	sub	r3, r3, #15
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L18
.L14:
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L20:
	.align	2
.L19:
	.word	300000
	.size	scroll, .-scroll
	.align	2
	.global	spi_write
	.syntax unified
	.arm
	.fpu vfp
	.type	spi_write, %function
spi_write:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	mov	r3, r0
	str	r1, [fp, #-20]
	strb	r3, [fp, #-13]
	mov	r3, r2
	strb	r3, [fp, #-14]
	ldrb	r3, [fp, #-13]	@ zero_extendqisi2
	lsl	r3, r3, #3
	uxtb	r3, r3
	and	r3, r3, #56
	uxtb	r3, r3
	strb	r3, [fp, #-12]
	mov	r3, #0
	strb	r3, [fp, #-11]
	mov	r3, #0
	strb	r3, [fp, #-10]
	mov	r3, #0
	strb	r3, [fp, #-9]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L22
.L23:
	ldrb	r3, [fp, #-14]	@ zero_extendqisi2
	sub	r2, r3, #1
	ldr	r3, [fp, #-8]
	sub	r3, r2, r3
	lsl	r3, r3, #3
	ldr	r2, [fp, #-20]
	lsr	r2, r2, r3
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	uxtb	r2, r2
	sub	r1, fp, #4
	add	r3, r1, r3
	strb	r2, [r3, #-8]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L22:
	ldrb	r3, [fp, #-14]	@ zero_extendqisi2
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L23
	ldrb	r3, [fp, #-14]	@ zero_extendqisi2
	add	r3, r3, #1
	mov	r2, r3
	sub	r3, fp, #12
	mov	r1, r2
	mov	r0, r3
	bl	bcm2835_spi_writenb
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	spi_write, .-spi_write
	.align	2
	.global	spi_read
	.syntax unified
	.arm
	.fpu vfp
	.type	spi_read, %function
spi_read:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	mov	r3, r0
	mov	r2, r1
	strb	r3, [fp, #-29]
	mov	r3, r2
	strb	r3, [fp, #-30]
	ldrb	r3, [fp, #-29]	@ zero_extendqisi2
	lsl	r3, r3, #3
	sxtb	r3, r3
	and	r3, r3, #56
	sxtb	r3, r3
	orr	r3, r3, #64
	sxtb	r3, r3
	uxtb	r3, r3
	strb	r3, [fp, #-20]
	mov	r3, #0
	strb	r3, [fp, #-19]
	mov	r3, #0
	strb	r3, [fp, #-18]
	mov	r3, #0
	strb	r3, [fp, #-17]
	mov	r3, #0
	strb	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-28]
	mov	r3, #0
	strb	r3, [fp, #-24]
	ldrb	r3, [fp, #-30]	@ zero_extendqisi2
	add	r3, r3, #1
	mov	r2, r3
	sub	r1, fp, #28
	sub	r3, fp, #20
	mov	r0, r3
	bl	bcm2835_spi_transfernb
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #1
	str	r3, [fp, #-12]
	b	.L25
.L26:
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #8
	sub	r1, fp, #28
	ldr	r2, [fp, #-12]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	orr	r3, r3, r2
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L25:
	ldrb	r3, [fp, #-30]	@ zero_extendqisi2
	ldr	r2, [fp, #-12]
	cmp	r2, r3
	ble	.L26
	ldr	r3, [fp, #-8]
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	spi_read, .-spi_read
	.align	2
	.global	wait_for_rdy
	.syntax unified
	.arm
	.fpu vfp
	.type	wait_for_rdy, %function
wait_for_rdy:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	str	r0, [fp, #-8]
	b	.L29
.L31:
	mov	r0, #1000
	bl	usleep
.L29:
	mov	r1, #1
	mov	r0, #0
	bl	spi_read
	mov	r3, r0
	and	r3, r3, #128
	cmp	r3, #0
	beq	.L30
	ldr	r3, [fp, #-8]
	sub	r3, r3, #1
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bne	.L31
.L30:
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	movgt	r3, #1
	movle	r3, #0
	uxtb	r3, r3
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	wait_for_rdy, .-wait_for_rdy
	.align	2
	.global	read_single_sample
	.syntax unified
	.arm
	.fpu vfp
	.type	read_single_sample, %function
read_single_sample:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r2, #3
	mov	r1, #524288
	mov	r0, #1
	bl	spi_write
	ldr	r0, .L36
	bl	usleep
	mov	r2, #3
	ldr	r1, .L36+4
	mov	r0, #1
	bl	spi_write
	ldr	r0, .L36
	bl	wait_for_rdy
	mov	r3, r0
	cmp	r3, #0
	bne	.L34
	mvn	r3, #0
	b	.L35
.L34:
	mov	r1, #3
	mov	r0, #3
	bl	spi_read
	mov	r3, r0
.L35:
	mov	r0, r3
	pop	{fp, pc}
.L37:
	.align	2
.L36:
	.word	5000
	.word	2097248
	.size	read_single_sample, .-read_single_sample
	.global	__aeabi_idiv
	.align	2
	.global	playTone
	.syntax unified
	.arm
	.fpu vfp
	.type	playTone, %function
playTone:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	ldr	r1, [fp, #-24]
	ldr	r0, .L41
	bl	__aeabi_idiv
	mov	r3, r0
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-24]
	ldr	r2, [fp, #-28]
	mul	r3, r2, r3
	ldr	r2, .L41+4
	smull	r1, r2, r2, r3
	asr	r2, r2, #6
	asr	r3, r3, #31
	sub	r3, r2, r3
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L39
.L40:
	mov	r1, #1
	mov	r0, #23
	bl	digitalWrite
	ldr	r3, [fp, #-12]
	mov	r0, r3
	bl	usleep
	mov	r1, #0
	mov	r0, #23
	bl	digitalWrite
	ldr	r3, [fp, #-12]
	mov	r0, r3
	bl	usleep
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L39:
	ldr	r2, [fp, #-8]
	ldr	r3, [fp, #-16]
	cmp	r2, r3
	blt	.L40
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L42:
	.align	2
.L41:
	.word	500000
	.word	274877907
	.size	playTone, .-playTone
	.align	2
	.global	playHappyChime
	.syntax unified
	.arm
	.fpu vfp
	.type	playHappyChime, %function
playHappyChime:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r1, #150
	ldr	r0, .L44
	bl	playTone
	ldr	r0, .L44+4
	bl	usleep
	mov	r1, #150
	ldr	r0, .L44+8
	bl	playTone
	ldr	r0, .L44+4
	bl	usleep
	mov	r1, #150
	mov	r0, #392
	bl	playTone
	ldr	r0, .L44+4
	bl	usleep
	mov	r1, #300
	ldr	r0, .L44+12
	bl	playTone
	nop
	pop	{fp, pc}
.L45:
	.align	2
.L44:
	.word	262
	.word	50000
	.word	330
	.word	523
	.size	playHappyChime, .-playHappyChime
	.align	2
	.global	playSadChime
	.syntax unified
	.arm
	.fpu vfp
	.type	playSadChime, %function
playSadChime:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r1, #300
	mov	r0, #440
	bl	playTone
	ldr	r0, .L47
	bl	usleep
	mov	r1, #300
	ldr	r0, .L47+4
	bl	playTone
	ldr	r0, .L47
	bl	usleep
	mov	r1, #300
	ldr	r0, .L47+8
	bl	playTone
	ldr	r0, .L47
	bl	usleep
	mov	r1, #400
	ldr	r0, .L47+12
	bl	playTone
	nop
	pop	{fp, pc}
.L48:
	.align	2
.L47:
	.word	50000
	.word	349
	.word	294
	.word	262
	.size	playSadChime, .-playSadChime
	.section	.rodata
	.align	2
.LC0:
	.ascii	"I2C init failed\000"
	.align	2
.LC1:
	.ascii	"SPI init failed\000"
	.align	2
.LC3:
	.ascii	"Error: ADC read fail\000"
	.align	2
.LC4:
	.ascii	"Soil is moist. No watering needed.\000"
	.align	2
.LC5:
	.ascii	"Attention: Water the plant!\000"
	.align	2
.LC2:
	.ascii	"\377\377\377\377\377"
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	bl	wiringPiSetup
	mov	r0, #39
	bl	wiringPiI2CSetup
	mov	r3, r0
	ldr	r2, .L59
	str	r3, [r2]
	ldr	r3, .L59
	ldr	r3, [r3]
	cmn	r3, #1
	bne	.L50
	ldr	r0, .L59+4
	bl	puts
	mvn	r3, #0
	b	.L58
.L50:
	bl	lcd_init
	bl	bcm2835_init
	mov	r3, r0
	cmp	r3, #0
	beq	.L52
	bl	bcm2835_spi_begin
	mov	r3, r0
	cmp	r3, #0
	bne	.L53
.L52:
	ldr	r0, .L59+8
	bl	puts
	mov	r3, #1
	b	.L58
.L53:
	mov	r0, #1
	bl	bcm2835_spi_setBitOrder
	mov	r0, #3
	bl	bcm2835_spi_setDataMode
	mov	r0, #128
	bl	bcm2835_spi_setClockDivider
	mov	r0, #0
	bl	bcm2835_spi_chipSelect
	mov	r1, #0
	mov	r0, #0
	bl	bcm2835_spi_setChipSelectPolarity
	ldr	r2, .L59+12
	sub	r3, fp, #32
	ldm	r2, {r0, r1}
	str	r0, [r3]
	add	r3, r3, #4
	strb	r1, [r3]
	sub	r3, fp, #32
	mov	r1, #5
	mov	r0, r3
	bl	bcm2835_spi_writenb
	ldr	r0, .L59+16
	bl	usleep
	mov	r2, #3
	ldr	r1, .L59+20
	mov	r0, #2
	bl	spi_write
	ldr	r0, .L59+24
	bl	usleep
	bl	wiringPiSetupGpio
	mov	r1, #1
	mov	r0, #23
	bl	pinMode
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
.L57:
	bl	read_single_sample
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-16]
	cmn	r3, #1
	bne	.L54
	ldr	r0, .L59+28
	bl	scroll
	b	.L55
.L54:
	ldr	r3, [fp, #-16]
	ldr	r2, .L59+32
	cmp	r3, r2
	movls	r3, #1
	movhi	r3, #0
	uxtb	r3, r3
	str	r3, [fp, #-20]
	mov	r0, #0
	bl	time
	str	r0, [fp, #-24]
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	beq	.L56
	ldr	r0, .L59+36
	bl	scroll
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-8]
	sub	r3, r2, r3
	cmp	r3, #9
	ble	.L55
	bl	playHappyChime
	ldr	r3, [fp, #-24]
	str	r3, [fp, #-8]
	b	.L55
.L56:
	ldr	r0, .L59+40
	bl	scroll
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-12]
	sub	r3, r2, r3
	cmp	r3, #9
	ble	.L55
	bl	playSadChime
	ldr	r3, [fp, #-24]
	str	r3, [fp, #-12]
.L55:
	ldr	r0, .L59+44
	bl	usleep
	b	.L57
.L58:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L60:
	.align	2
.L59:
	.word	lcd
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	5000
	.word	3174409
	.word	90000
	.word	.LC3
	.word	430
	.word	.LC4
	.word	.LC5
	.word	500000
	.size	main, .-main
	.ident	"GCC: (Raspbian 10.2.1-6+rpi1) 10.2.1 20210110"
	.section	.note.GNU-stack,"",%progbits
